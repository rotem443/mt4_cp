
////////////////////////////////////////////////////////////////////////////////////////////////
// iSpreadToolAL_ATI: Copyright (c) 2011,2013 Ati
////////////////////////////////////////////////////////////////////////////////////////////////

FIRST: READ ALL: will speed up what you want to do

THIS is an INDICATOR for Metatrade MT4: which will help record/analyze spread.
- Historical spread (record spread to file / read spread from file) 
- Plot current Spread: Per Bar 
    - Max/Min/Average Spread
    - Tick Number as well as Volume
- Plot of All historical Spread bars:
    - Highest/Lowest
- Optional Alert at SpreadLevel reached


::: General Info :::

* Tick Count vs. Volume:
    - Volume value is the Broker send volume
    - Tick Count is the tick loops thw indicator processes
        - this is very often much less than the actual Volume
            - probably different reasons: e.g. internet latency
            But I have noticed this also in quite slow market conditions

    - IMPORTANT: if Tick Count is less than Volume: it means there could have been other Ticks with Higher/Lower spread so this is not 100%
    - Average Spread is always calculated on the bases of Tick count: because this is what the indicator processed

* CSV HistoricalSpread File: I write it on purpose into an csv file so that one could open it for instance in an spreadsheet application: e.g. excel

* if the indicator is attached it when the terminal is started: sometimes it might (not usually) mess things up: 
    - problem of MT4 re adjusting internally bars if some needed to be downloaded.

* Do not use 2 times b.Read_Write_HistoricalSpread on the same Symbol/same TF
    - e.g. 2 EURUSD M1 charts where b.Read_Write_HistoricalSpread is set to true.
    Reason they would both write to the same file and it is not clear what would happen (e.g. souble entries ect..)
    one can still aplly the indicator to both but set only on one: b.Read_Write_HistoricalSpread to trueon all other charts to false

    - if the charts use different TF or Symbol there should be no problem



------------------------------------------------------------------------------------------------------

==== IMPORTANT ==== READ ALSO THE INFO at the scripts: Input Tab.
In case of an ERROR: read the comment: and the PopUp Alert


DISCLAIMER: !!!USE AT OWN RISK!!! You assume <full responsibility> for all risk associated.

==== INSTALL: ====
1. Quite MT4
2. Copy the INDICATOR FILE: iSpreadToolAL_ATI.ex4 to the - MetaTraderFolder/experts/indicators
3. restart MT4

==== REQUIRED FIRST STEP: ====
- PRODUCE HELP/README FILE
    - SET: b.HELP to true and run the script
        A HELP files will be created in: MetaTraderFolder/experts/files/
        All other Info will be there
        - if not existing it will create also the Folder structure:
        - MetaTraderFolder\experts\files\spreadhistory




==== INPUT VARIABLES ====

0. b.HELP:
    - set it to true and run the script to output the Help info as well as creating initial Directories


------------------------------------------ Historical Spread ------------------------------------------

1. b.Read_Write_HistoricalSpread

    - if true we read SpreadHistory from file (if it exists in MetaTraderFolder\experts\files\spreadhistory) and also write live spreads to file
        - this are CSV files which can be opened for instance in spreadsheet applications like e.g.: excel.


2. b.Overwrite.Existing.File

    - if true an existing SpreadHistory File will be overwritten: if false new live spreads will be appended


3. s.CSV.Delimiter

    - Delimiter for CSV: SpreadHistory File

--------------------------------------------- PLOT Spread --------------------------------------------- 


4. b.MAXspread.Bars

    - if true Max Spread will be plotted as Histogram: if false as line


5. c.MAXspread

    - Color for Max Spread


6. i.MAXspread.Width

    - width of Max Spread histogram bars or width of line


7. b.AVERAGEspread.Bars

    - if true Average Spread will be plotted as Histogram: if false as line


8. c.AVERAGEspread

    - Color for Average Spread


9. i.AVERAGEspread.Width

    - width of AVERAGEspread histogram bars or width of line


10. b.MINspread.Bars

    - if true Min Spread will be plotted as Histogram: if false as line


11. c.MINspread

    - Color for Min Spread


12. i.MINspread.Width

    - width of Min Spread histogram bars or width of line


---------------------------------------------- PLOT INFO ---------------------------------------------- 

13. b.Plot_Info 

    - if true an additional InfoPanel is plotted: with info to the active(last) bar and the Highest/Lowest spread of all loaded HistoricalSpread Bars


14. i.Window.Num

    - Window Number where to plot the InfoPanel: default -1 is in the subwindow where the Historical Spread is plotted: use 0 for the main chart window or any other Subwindow number


15. c.InfPanel

    - Background color of the InfoPanel


16. i.InfPanel.X

    - moves the whole InfoPanel horizontal


17. i.InfPanel.Y

    - moves the whole InfoPanel vertical


18. c.Titel.Txt

    - InfoPanel: Titel color


19. c.Spread.Txt

    - InfoPanel: Current spread(Now) color


20. c.AVERAGEspread.Txt

    - InfoPanel: Average spread color


21. c.MAXspread.Txt

    - InfoPanel: Max spread color


22. c.MINspread.Txt

    - InfoPanel: Min spread color


23. c.TICKScount.Txt

    - InfoPanel: Tick Count color


24. c.Volume.Txt

    - InfoPanel: Volume color


25. c.HighestLowestSpread.Txt

    - InfoPanel: Color of Highest/Lowest spread of all loaded HistoricalSpread Bars


------------------------------------------------ ALERT ------------------------------------------------ 

26. b.SoundAlert.On

    - If True: SoundAlert will be triggered when: Live ticks reach the d.Alert.Spread.PipsLevel (Not for historical read Spread Data)


27. s.SpreadAlert.SoundFileName

    - Valid MT4 compatible Sound filename to be used as alert: must exist in MetaTraderFolder/Sounds
      - if one runs the tool on different charts one could use different soundfiles for alerts: e.g. one per symbol
          - maybe record your own and say the symbolname


28. d.Alert.Spread.PipsLevel

    - Spread Pips Level: if reached the Soundalert will be triggered


29. i.MinSeconds.BetweenAlerts

    - To Avoid sounding all the time if the Spread stays higher than the predefined Level
      - example to Alert only once set it to something extrem high: 100000 which is a bit more than a day
    - NOTE: Set this to 0 and d.Alert.Spread.PipsLevel to 0.0 and one should here each incoming tick


Cheers
ATI

