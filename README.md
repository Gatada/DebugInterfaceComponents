# Debug Interface Components

A small collection of simple tools made to help debug a Godot game I'm working on. They are marked with `@tool` which means they will both update live in the editor.

## Debug Meter 2D
A simple customzable 2D control node for Godot that works as a meter. It takes a float input and represents it by the height of the meter (also shows the value below the meter).

Set up the meter with a max and min value, customize the colors and set the relative location of the baseline. The baseline is a way to identify a marker for a desired target value.

## Debug State Label 2D
This is a customzable label with a highlight state that can be toggled on and off.

I hope you find them useful.
Gatada

# Installation

This addon can be install in two ways: via the Asset Library within the Godot editor or manually.

## Using the Asset Library:
* Open the Godot editor.
* Navigate to the AssetLib tab at the top of the editor and search for "Debug Interface Components".
* Install the addon by clicking Download.
* The components will not be available in tools/debuginterfacecomponents/.


## Manual installation

Manual installation lets you use pre-release versions of this add-on by following its master branch.

## Clone this Git repository

`git clone https://github.com/Gatada/DebugInterfaceComponents.git`

Alternatively, you can download a ZIP archive if you do not have Git installed.

Move the tools/ folder to your Godot project folder.


# Usage

1. Drag a packed scenes onto your scene from from any of the folders within `tools/debuginterfacecomponents/`.
2. Then proceed to customize the meter (as they are tools, all changes will update live in the editor).
3. Finally, call the instance to update its state. Check the documentation of the component you use by clicking `Search Help` within the Godot editor.


# Sound Effects is in the Demo

The sound effects heard in the demo are made by Kenney (www.kenney.nl). They are free to use in personal, educational and commercial projects.
It is available from the AssetLib in the Godot editor as a free download.

To find this library as an addon, search the AssetLib for "Kenney Interface Sounds".

Donate to Kenney:   http://support.kenney.nl
Support Kenney using Patreon:  http://patreon.com/kenney/
Follow Kenney on Twitter for updates: http://twitter.com/KenneyNL
	

# License

Copyright © 2022 Gatada.

See LICENSE.md to read the MIT license.
