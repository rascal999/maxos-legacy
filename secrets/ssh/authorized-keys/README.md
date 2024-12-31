# SSH Authorized Keys

This directory contains age-encrypted SSH authorized keys for each user.

## File Structure

Each user should have their own `.age` file:
- `root.age` - Root user's authorized keys
- `user.age` - Default user's authorized keys
- etc.

## Creating Key Files

1. Create a plain text file with the authorized keys:
```bash
# keys.txt
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host
```

2. Encrypt it using age:
```bash
age -r "age1..." -o user.age keys.txt
```

3. Add the encrypted file to this directory

## Key File Format

The decrypted content should be a newline-separated list of SSH public keys:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... key1
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... key2
```

## Integration

The ssh-keys module will:
1. Decrypt these files using the system's age key
2. Apply the keys to the appropriate users
3. Store them in /etc/ssh/authorized_keys.d/
