# SafeCyling

This repository contains all the software used for the analysis of the data collected during the master thesis of Anouck Matthijs and Theresa De Ryck. All subjects did a cycling parkours on a conventional bike and e-bike while cycling at preferred speed, half the preferred speed and preferred speed in combination with a dual task (identifying pictures of objects). All details of the cycling parcours, collected data and ... can be found in the thesis of Anouck and Theresa and the journal publication (work in progress).

## Overview of data processing

IMU data was processed in MTManager (computing rotation matrices with sensor orientation). The resulting .txt files were processed in the script ExampleBatch2.m

```matlab
Examples/ExampleBatch2.m
```

This script combines the raw txt files and save it as .mat files in a specific folder (for more information see manual in folder InfoProcessing). 

### Axis steering angle

GetRotationAxisSteer_Subjects:** Computes function axis of the stem (i.e. steering angle) and stores this as a new .mat file (RotAxis_Steer.mat) for each subject and each type of bike. Details on the methods for detecting the steering angle is in *./Manuals/RotationStem/*

### Data in phases cycling parcours

*More detailed information on data analysis can be found in the manual: Manuals/InfoProcessing.m*

After running the script to convert the .mtb files to .mat files, there are multiple scripts to compute outcomes variables in the dataset. The first step is to assign parts of the full time-series with sensor information to parts in the cycling parkours. This is mainly done using a pulse that was send by the test leader. This was adapted for some specific cases using a GUI that you can run using the script CleanUp_TriggerPulses. Detailed information on the GUI can be found in (*Manuals/GUI_Triggers*)

```
CleanUp_TriggerPulses.m
```

The variable tTrigger is adapted in each .mat files based on the user input. Note that the original timing of the triggers is still stored in the variable Data in the matfile. Subsequently the script  **GetData_Phases** then selects the data between the trigger pulses.

```matlab
GetData_Phases.m
```

This script adds a new variable (Phases) to the matfile with the raw data and steering angle in each phase of the cycling parcours.

## Shoulder check

The sensor orientations during the shoulder check is analyzed using the script **Example_ShoulderCheck.m**. This script creates one large data matrix with alle information on bike-type, cycling-speed, Age, sensor orientations, ... . The start and end of the shoulder check phase was detected manually using the GUI in when running script **DetectPhasesShoulderCheck.m**. You can find more information on this GUI in *Manuals/GUI_shoulderCheckEvents.m*. 

### Reading the excel file with descriptive information

ReadInfoExcel.m**: reads info from the excel file 'opmerkingen proefpersonen' and stores general information such as the folder name of the young and older subjects.







