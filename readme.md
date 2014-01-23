# Shipbuilder

HTML/DART based editor for [SpaceEngineer](http://www.spaceengineersgame.com/) Ships.

## Features
> * Edit ship layer by layer
> * Export ship to XML (still have to copy paste into .sbs for level)
> * Different Colored Blocks (no white color or default color atm)
> * Small or Large Block Types
> * Position Sliders (maybe change to textboxes)
> * Side pictures to show layer above and below

## Planned Features
> * Full world exporting
> * Ship importing
> * More block types

## Use
> * BE SURE TO MAKE A BACKUP OF THE WORLD
> * Visit a [live example](https://dl.dropboxusercontent.com/u/45992589/shipbuilder/shipbuilder.html) and make your ship
> * Be sure to select a position that is away from anything else in your world
> * When you are done, click the export button and it should download the ship as a .xml file
> * Next open it with notepad or a similar editor
> * And open up the world's .sbs file and insert near the end of the file, inbetween the following xml tags


    </MyObjectBuilder_EntityBase>
    pastefile contents here
    </SectorObjects>


> * From there load it up in SpaceEngineers and look at your work

  
## Contributing
[Download](https://www.dartlang.org/) the dart IDE. And go to File->Open Existing Folder and navigate to where you have the files downloaded.

You can start coding from there!

## License
See LICENSE file (MIT)