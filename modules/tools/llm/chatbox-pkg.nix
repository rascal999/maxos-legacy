{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, electron
, nodejs
, nodePackages
}:

stdenv.mkDerivation rec {
  pname = "chatbox";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "Bin-Huang";
    repo = "chatbox";
    rev = "v${version}";
    sha256 = "sha256-Ue2NqKh9GwZzHQX3zF1YMhkHHXOmL+idZEk/YqxZQvk="; # Will be updated after first attempt
  };

  nativeBuildInputs = [ nodejs nodePackages.pnpm makeWrapper ];
  buildInputs = [ electron ];

  buildPhase = ''
    export HOME=$(mktemp -d)
    pnpm install
    pnpm run build
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/512x512/apps

    # Copy app files
    cp -r dist/linux-unpacked/* $out/
    cp build/icon.png $out/share/icons/hicolor/512x512/apps/chatbox.png

    # Create wrapper
    makeWrapper ${electron}/bin/electron $out/bin/chatbox \
      --add-flags "$out/resources/app.asar"

    # Create desktop entry
    cat > $out/share/applications/chatbox.desktop << EOF
    [Desktop Entry]
    Name=Chatbox
    Exec=chatbox
    Icon=chatbox
    Type=Application
    Categories=Development;Utility;
    Comment=ChatGPT/LLMs UI Client
    EOF
  '';

  meta = with lib; {
    description = "A cross-platform desktop client for ChatGPT/LLMs";
    homepage = "https://github.com/Bin-Huang/chatbox";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [];
  };
}
