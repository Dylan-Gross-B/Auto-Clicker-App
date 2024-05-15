# Auto-Clicker App
## Description
This Auto-Clicker app provides an easy way to rapidly click without the hassle of dealing with AutoHotKey and providing a simple interface to change settings. Its written in PowerShell and uses WPF for the GUI.

<p align="center">
  <img src="https://github.com/Dylan-Gross-B/Auto-Clicker-App/assets/169424511/228473c9-604a-4090-a581-de69ce2d79b5" />
</p>

## Settings:
_Delay between Clicks (ms)_ - This is how long the script will sleep (in milliseconds) in between clicks. I don't recommend going below 2.

_HotKey: Start Run_ - This is the keyboard button that will initiate the clicking function. This does need to be a button the script can recognize as a string.

_HotKey: Interrupt Run_ - This keyboard button will stop the click operation at whatever step in the process it is and return to the state before the **Launch** button was pressed.

Will work as hotkey:
- Letters (a-z, case-insensitve)
- Numbers (0-9, doesn't differentiate between numbers above letters from a numpad. They're treated as the same button)
- Symbols ( , . / ; ' [ ] - = \ / * - + , Anything that doesn't need shift to access the symbol as the button press is detected and turned into a string to compare)
  
Other keys that won't work as a hotkey:
- Shift, Tab, Ctrl, Enter
- F* keys

_Number of Loops_ - This is how many times the click loop will execute. The click loop consists of 1) Pressing down the left click, 2) Releasing the left click, 3) Sleeping for the assigned delay period.

## How to Use:
This repo has two files: 
- A powershell script that this was written in
- And an .exe that can be used to launch this if you don't want to open powershell

1. Download the script / app however you want to use it. The .exe can just be ran. The .ps1 will launch through powershell. 
> [!NOTE]
> Your anti-virus is likely to flag this tool as it does have behavior that mimics a keylogger. It will listen for key presses to activate the hot key buttons. However the keys pressed aren't logged anywhere.
2. Adjust your settings however you'd like and press the **Launch** button. The tool will then enter a listening state.
3. From here you can press the **HotKey: Start Run** button assigned and it will execute the auto-clicking function. This will continue until it has reached its loop limit or until the **HotKey: Interrupt Run** button is pressed.
4. If the auto-clicking function stopped from reaching its loop limit, it can be restarted by simply pressing the same **Start Run** key again. However if the function was stopped by pressing the **Interrupt Run** button, you will need to press the **Launch** button again to have it re-enter its listening state. 
5. To change settings, its preferrable to make sure the tool is not in its _Listening_ state. Press the **Interrupt** button if you've already pressed the **Launch** button. 

## Common Log Outputs:
Cannot validate argument on parameter 'ID'
![image](https://github.com/Dylan-Gross-B/Auto-Clicker-App/assets/169424511/36776d4f-dab9-4f4e-be59-1ca4eee28bf8)
- This just means that you exited the "Listening" state without the clicking function executing. This isn't a problem, its just the exit function trying to remove a job that doesn't exist.

Command cannot remove the job because it does not exist...
![image](https://github.com/Dylan-Gross-B/Auto-Clicker-App/assets/169424511/192d75a3-3bd9-4c4c-a3b9-8765f5690cf7)
- This is similarly a non-issue. The click function exited properly and the exit function tried to remove a job that was already removed.

## Contributing
We welcome any and all contributions! Here are some ways you can get started:
1. Report bugs: If you encounter any bugs, please let us know. Open up an issue and let us know the problem.
2. Contribute code: If you are a developer and want to contribute, follow the instructions below to get started!
3. Suggestions: If you don't want to code but have some awesome ideas, open up an issue explaining some updates or imporvements you would like to see!
4. Documentation: If you see the need for some additional documentation, feel free to add some!

## Instructions
1. Fork this repository
2. Clone the forked repository
3. Add your contributions (code or documentation)
4. Commit and push
5. Wait for pull request to be merged
