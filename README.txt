How to run the project

1. The project has been developed on Xcode 9.3 and requires you to have it installed on your macOS for successfully compiling and running this project.
2. This application is compatible with macOS versions 10.10+
3. This project requires you to have ffmpeg open source repositories installed on your mac. Pre compiled binary can also be used instead of direct installation.
4. To install homebrew, Open Terminal and type the following command:

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

5. After homebrew, you need open source ffmpeg repositories to be installed. Type the following command in Terminal:

brew install ffmpeg --with-tools --with-fdk-aac --with-freetype --with-fontconfig --with-libass --with-libvorbis --with-libvpx --with-opus --with-x265 --with-x264

6. Open the Xcode project. Change the URL pointing to your desktop
7. Clean and Build the project > Run


The project helps encoding binary RAW files and applies an encoder to it and also helps interconverting videos by letting you choose from 3 containers (MKV, MP4, AVI) and 3 encoders (H.265, H.264 and VP9)