//test


U0 SongTask()
{
 Fs->task_end_cb=&SndTaskEndCB;
 MusicSettingsRst;
 while(TRUE){
  music.tempo = 4;
  music.stacatto_factor = 1;
  Play("5eE5Er5Er5C5Erh5G4hrGr");
  Play("q5Cr4GrErArBrB#Ar");
  Play("G5ErGqAeFGrqEeCD4hBr");
  Play("5qCr4GrErArBrB#rArG");
  Play("e5ErGrArFGrErCD4hBrr");
  Play("5eGF#FD#rEr4A#A5Cr4A5CDr");
  Play("5GF#FD#rE6CrChCr");
  Play("5eGF#FD#rEr4A#A5Cr4A5CDr");
  Play("5D#rrDrhCr");
  Play("5eG5F#5F5D#r5Er4A#4A5Cr4A5C5Dr");
  Play("5G5F#5F5D#r5E6Cr6Ch6Cr");
  Play("5eG5F#5F5D#r5Er4A#4A5Cr4A5C5Dr");
  Play("5D#r5Drh5Cr");
  Play("4eC4Cr4Cr4C4Dr4E4C3r3Ah3G");
  Play("4eC4Cr4Cr4C4Dw4E");
  Play("4eC4Cr4Cr4C4Dr4E4C3rAh3G");
  Play("5eE5Er5Er5C5Erh5G4hrGr");
  Play("q5Cer4GrErArBrB#Ar");
  Play("G5ErGqAeFGrqEeCD4hBr");
  Play("q5Cer4GrErArBrB#Ar");
  Play("G5ErGqAeFGrqEeCD4hBr");
  Play("5eECr4GrA#A5FrF4Ar");
  Play("4eB5AAAGFEC4rAGrr");
  Play("5eECr4GrA#A5FrF4Ar");
  Play("4eB5FrFFEDhCrr");
  Play("4eB5AAAGFEC4rAGrr");
  Play("5eECr4GrA#A5FrF4Ar");
  Play("4eB5FrFFEDhCrr");
  Play("4eC4CrCrCDrEC3rAhG");
  Play("4eC4CrCrCDwE");
  Play("4eC4CrCrCDrEC3rAhG");
  Play("5eE5Er5Er5C5Erh5G4hrGr");

 }

}
U0 AnimateTask()
{
 while(TRUE){
  if(jumpSoundActive){
   music.tempo=32;
   Play("e4D4C#4D4D#4E4F4F#4G4G#A4A#4B5C5C5#D4"); //blocks here, which is fine in this thread
   music.stacatto_factor = 1;
   music.tempo=4;
   jumpSoundActive = 0;
  } else if (coinSoundActive){
   music.tempo=12;
   Play("e6B7hEr4");  
   music.stacatto_factor = 1;
   music.tempo=4;
   coinSoundActive = 0;
  } else if(powerUpSoundActive){
   music.tempo=32;
   Play("e5C4G5C5E5G6C5G4G#5C5D#5D#5G#5G#6C6D#6E#6D#4A#5D5F5A#5F5A#6D6F6A#6F4");
   music.stacatto_factor = 1;
   music.tempo=4;
   powerUpSoundActive = 0;
  } else if(powerUpAppearSoundActive){
   music.tempo=11;
   Play("e4C4G4G#4C#4G#4A4D4A4A#4E#4A#4qB");
   music.stacatto_factor = 1;
   music.tempo=4;
   powerUpAppearSoundActive = 0;
  }

  Yield;  // or Sleep(1) depending on your system
 }
}
