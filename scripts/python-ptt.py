#!/usr/bin/env python3

# python-ptt.py - Python-based Push-to-Talk using evdev
# Author: Roo
# Date: 2025-11-21

import os
import sys
import subprocess
import time
from evdev import InputDevice, UInput, ecodes, AbsInfo # Import UInput and AbsInfo

# Configuration
AUDIO_DEVICE_ID = "116"  # Jabra EVOLVE 20 MS Mono (ID from wpctl status)
MOUSE_DEVICE_PATH = "/dev/input/event3"  # G502 X mouse
TARGET_KEY_CODE = ecodes.BTN_SIDE
KEY_PRESS_VALUE = 1
KEY_RELEASE_VALUE = 0

# Logging helper
def log_info(message):
    print(f"[INFO] {message}", flush=True)

def log_error(message):
    print(f"[ERROR] {message}", file=sys.stderr, flush=True)

def log_warning(message):
    print(f"[WARNING] {message}", flush=True)

def run_wpctl_command(args):
    """
    Executes wpctl commands.
    Relies on wpctl being in PATH for the service.
    """
    try:
        command = ["wpctl"] + args
        log_info(f"Executing: {' '.join(command)}")
        process = subprocess.run(command, capture_output=True, text=True, check=False, timeout=5)
        if process.returncode != 0:
            log_error(f"wpctl command failed (code {process.returncode}): {process.stderr.strip()}")
            log_error(f"wpctl stdout: {process.stdout.strip()}")
            return False
        log_info(f"wpctl output: {process.stdout.strip()}")
        return True
    except subprocess.TimeoutExpired:
        log_error(f"wpctl command timed out: {' '.join(command)}")
        return False
    except FileNotFoundError:
        log_error(f"wpctl command not found. Ensure it's in PATH for the service. Searched for: {command[0]}")
        return False
    except Exception as e:
        log_error(f"Exception running wpctl: {e}")
        return False

def set_mic_mute(muted: bool):
    state_value = "1" if muted else "0"
    action_desc = "Muting" if muted else "Unmuting"
    log_info(f"{action_desc} microphone (ID: {AUDIO_DEVICE_ID})")
    if not run_wpctl_command(["set-mute", AUDIO_DEVICE_ID, state_value]):
        log_error(f"Failed to {action_desc.lower()} microphone.")

def main():
    log_info("=== Python Push-to-Talk Script v2 ===")
    log_info(f"Monitoring device: {MOUSE_DEVICE_PATH} for key code {TARGET_KEY_CODE}")
    log_info(f"Controlling audio device ID: {AUDIO_DEVICE_ID}")

    if not os.path.exists(MOUSE_DEVICE_PATH):
        log_error(f"Mouse device not found: {MOUSE_DEVICE_PATH}")
        sys.exit(1)

    try:
        device = InputDevice(MOUSE_DEVICE_PATH)
    except PermissionError:
        log_error(f"Permission denied for {MOUSE_DEVICE_PATH}. "
                  f"Ensure the user running this script (e.g., via systemd) "
                  f"has read/write access (e.g., member of 'input' group and udev rules).")
        sys.exit(1)
    except Exception as e:
        log_error(f"Failed to open device {MOUSE_DEVICE_PATH}: {e}")
        sys.exit(1)

    log_info(f"Successfully opened device: {device.name}")

    # Create a uinput device to re-emit events
    uinput_device = None
    try:
        # Define capabilities for the uinput device based on the grabbed device
        # This ensures we can re-emit all events the original device produces
        cap = device.capabilities(verbose=False) # Use False for raw capabilities
        # Filter out EV_SYN from capabilities for UInput, as it's handled automatically
        filtered_cap = {ev_type: codes for ev_type, codes in cap.items() if ev_type != ecodes.EV_SYN}
        
        # If EV_ABS is present, ensure AbsInfo is provided if needed by UInput constructor
        # For simplicity, we'll rely on UInput's default handling or provide basic AbsInfo if it errors.
        # A more robust way is to copy AbsInfo from the source device if possible.
        # For now, let's try without explicit absinfo unless UInput complains.
        # Example of how to get absinfo:
        # abs_info_map = {}
        # if ecodes.EV_ABS in filtered_cap:
        #     for code in filtered_cap[ecodes.EV_ABS]:
        #         abs_info_map[code] = device.absinfo(code)
        # uinput_device = UInput(filtered_cap, name='python-ptt-reemitter', absinfo=abs_info_map if abs_info_map else None)

        uinput_device = UInput(filtered_cap, name='python-ptt-reemitter')
        log_info("Successfully created uinput device for re-emitting events.")
    except Exception as e:
        log_error(f"Failed to create uinput device: {e}. Mouse/keyboard pass-through will not work.")
        # Continue without uinput if it fails, but log prominently. PTT might still work.

    log_info("Initializing microphone to muted state.")
    set_mic_mute(True)

    try:
        with device.grab_context():
            log_info(f"Device {MOUSE_DEVICE_PATH} grabbed. Monitoring for events...")
            for event in device.read_loop():
                if event.type == ecodes.EV_KEY and event.code == TARGET_KEY_CODE:
                    if event.value == KEY_PRESS_VALUE: # Key pressed
                        log_info(f"Target key {event.code} pressed.")
                        set_mic_mute(False)
                    elif event.value == KEY_RELEASE_VALUE: # Key released
                        log_info(f"Target key {event.code} released.")
                        set_mic_mute(True)
                    # Do not re-emit the target key event itself
                else:
                    # Re-emit other events (mouse movements, other clicks, keyboard presses)
                    if uinput_device:
                        try:
                            uinput_device.emit(event.type, event.code, event.value)
                            # log_info(f"Re-emitted: type {event.type}, code {event.code}, value {event.value}")
                        except Exception as e:
                            log_error(f"Failed to re-emit event (type {event.type}, code {event.code}, value {event.value}): {e}")
                    else:
                        # If uinput device failed, we can't re-emit. Mouse will be stuck.
                        # This branch should ideally not be hit if uinput setup is robust.
                        pass
    except KeyboardInterrupt:
        log_info("Script interrupted by KeyboardInterrupt. Releasing device and exiting.")
    except Exception as e:
        log_error(f"An error occurred during event monitoring: {e}")
        import traceback
        log_error(traceback.format_exc()) # Log full traceback
    finally:
        log_info("Ensuring microphone is muted on script exit.")
        set_mic_mute(True)
        if 'uinput_device' in locals() and uinput_device:
            try:
                log_info("Closing uinput device.")
                uinput_device.close()
            except Exception as e:
                log_error(f"Error closing uinput device: {e}")
        if 'device' in locals() and device.fd != -1: # Check if device was opened and fd is valid
            try:
                # Ungrab is handled by context manager, but close fd
                log_info("Closing original input device.") # Clarified log
                device.close()
            except Exception as e:
                log_error(f"Error closing original input device: {e}") # Clarified log
        log_info("Push-to-Talk script stopped.")

if __name__ == "__main__":
    main()
