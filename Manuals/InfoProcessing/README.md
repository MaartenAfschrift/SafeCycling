# Processing IMU data : Cycling project

## Processing in MT manager

You have to start MT manager 4.6 and use the export tool to export the information in the .mtb files to txt files. In this old version of the software, this is unfortunatly a manual process. 

### Configure the export tool

First you have to configure the export tool:

- Open Tools->Preferences
- Change the Output Filename and tick the right boxes similar to this figure. Make sure that you do this correct (otherwise you'll have to do all the next steps again)

<img src="figs/ExportTool.png" style="zoom:75%;" />



- Manually export the files one by one.

  for i=1:nfiles

  - Change the current directory (top right on screen) to a specific folder.
  - Click on the icon to open file.
  - Select an .mtb file you want to export
  - Click on the export button

  end

## Convert .mtb files to .mat files and comine data of sensors 

You can run the script **ExampleBatch2.m** and the script **Example_StandingBalance** to read all the .txt files and create .mat files with all the data in the right format. These scripts combines the data of the (6) different sensors, detects the trigger pulses and checks if datapoints are missing. matlab will print warning messages in the command window when more than 5% of the data is missing in a file. These warnings are safed in a text file (LogBatchProcessing.txt). To run these scripts you have to point to the right paths on your computer (on line5-8 in the script). For example in my case:

```matlab
MainPath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Software';
datapath = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Data\EXPERIMENTEN';
OutPath  = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Data\MatData';
OutFigures = 'C:\Users\u0088756\Documents\Teaching\MasterThesis\Anouck_Theresa\Data\Figures';

```

Matlab will also print figures of the angular acceleration in the world frame. This gives you a good idea of the quality of each trial/experiment. These figures are save in the folder "OutFigures" (see above). You can choose if you want to close these figures automatically or not (adviced when you process all the data, otherwise you'll have a lot of figures !) 

```matlab
Bool_CloseFig = 1;
```

The script:

- **ExampleBatch2.m**: converts the data of the cycling parcours
- **Example_StandingBalance.m**: converts the standing balance data (and also computes already the outcome variables)

### Compute outcomes

After running the script to convert the .mtb files to .mat files, there are multiple scripts to compute outcomes variables in the dataset. I advise you to run these scripts in the following order

1. **CleanUp_TriggerPulses.m:** This scripts uses a GUI to correct for errors in the trigger pulses. The variale tTrigger is adapted in each .mat files based on the user input. Note that the original timing of the triggers is still stored in the variable Data in the matfile.
2. **GetRotationAxisSteer_Subjects:** Computes function axis of the stem (i.e. steering angle) and stores this as a new .mat file (RotAxis_Steer.mat) for each subject and each type of bike
3. **GetData_Phases:** Adds a new variable (Phases) to the matfile with the raw data and steering angle in each phase of the cycling parcours.
4. **ReadInfoExcel.m**: reads info from the excel file 'opmerkingen proefpersonen' and stores general information such as the folder name of the young and older subjects

After running these three scripts we have all the required data in the right format. You can now write you own scripts to compute outcome variables. I made an example that computes the variance in steering angle during the first part of the parcours where the subjects bikes in a narrow lane (**Example_NarrowLane.m**).

## To Do: 

- List of older subjects (we have to determine if subject is young or old)













