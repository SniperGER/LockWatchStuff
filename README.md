# LockWatch
## A tweak to display Apple Watch watchfaces on your lockscreen

Haven't worked on it for quite some time, so I actually don't know which is the most recent one.
There are a few demo versions (those that are compiled in Xcode and deployed as an app), a few Tweak versions (compiled with Theos) and Tweaks compiled with Xcode & Theos.
Probably even some standalone watch faces. I don't know, honestly.

The "Extras" folder contains image bundles that go into "/var/mobile/Library/LockWatch/Image Bundles".
Compiled watch faces are loaded from "/var/mobile/Library/LockWatch/Watch Faces".

If you're compiling your own watch face, keep in mind that it requires the com.apple.backboard.client entitlement so it's able to run on SpringBoard.

Please don't judge me for the coding style. This is my first ever serious ObjC project.