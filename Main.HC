#include "Wad.HC";
#include "Globals.HC";
#include "Level.HC";
#include "Game.HC";
#include "Draw.HC";

U0 SongTask()
{
 Fs->task_end_cb=&SndTaskEndCB;
 MusicSettingsRst;
 while(TRUE){
  music.tempo = 4;
  music.stacatto_factor = 1;
  Play("5eEErErCErhG4hrGr");
  Play("q5Cer4GrErArBrB#Ar");
  Play("G5ErGqAeFGrqEeCD4hBr");
  Play("5qCr4GrErArBrB#rArG");
  Play("e5EGAFGrErCD4hBrr");
  Play("5eGF#FD#rEr4A#A5Cr4A5CDr");
  Play("5GF#FD#rE6CrChC");
  Play("5eGF#FD#rEr4A#A5Cr4A5CDr");
  Play("5D#rrDrhCr");
  Play("5eGF#FD#rEr4A#A5Cr4A5CDr");
  Play("5GF#FD#rE6CrChC");
  Play("5eGF#FD#rEr4A#A5Cr4A5CDr");
  Play("5D#rDrhCr");

 }

}
U0 AnimateTask()
{
 while(TRUE){
  if(jumpSoundActive){
   jumpSoundActive = 0;

   music.tempo=24;
   Play("e4DC#DD#EFF#GG#AA#B5CC#D"); //blocks here, which is fine in this thread
   music.tempo=4;
  }

  Yield;  // or Sleep(1) depending on your system
 }
}
U8 *WORLD_FILE = MStrPrint("%s%s",DirCur,"/Levels/World1-1.TXT");

U0 MarioMain()
{
 CDC *dc = DCAlias;
 I64 arg1, arg2;
 U8 input;

 SettingsPush; WinMax; WinBorder;
 DocCursor; DocClear;

 InitMario();
 clvl = LoadLevel(WORLD_FILE);
 Fs->draw_it = &DrawMarioGame;
 Fs->song_task=Spawn(&SongTask,Fs);
 Fs->animate_task=Spawn(&AnimateTask,Fs);

 while(TRUE){
  while( input = GetMsg(&arg1,&arg2,
     1<<MSG_KEY_DOWN | 1<<MSG_KEY_UP))
  {
 
  switch(input)
  {
   case MSG_KEY_DOWN:
    switch(arg1)
    {
     case 'a': case 'A': keyL = 1; break;
     case 'd': case 'D': keyR = 1; break;
     case 'w': case 'W': case ' ': keyJump = 1; break;
     case CH_ESC: goto fs_end;
    }

    if(arg1 == 0){
     switch(arg2.u8[0]){
      case SC_CURSOR_LEFT:  keyL = 1; break;
      case SC_CURSOR_RIGHT: keyR = 1; break;
      case SC_CURSOR_UP:    keyJump = 1; break;
     }
    }
   break;

   case MSG_KEY_UP:
    switch(arg1)
    {
     case 'a': case 'A': keyL = 0; break;
     case 'd': case 'D': keyR = 0; break;
     case 'w': case 'W': case ' ': keyJump = 0; break;
    }

    if(arg1 == 0){
     switch(arg2.u8[0]){
      case SC_CURSOR_LEFT:  keyL = 0; break;
      case SC_CURSOR_RIGHT: keyR = 0; break;
      case SC_CURSOR_UP:    keyJump = 0; break;
     }
    }
   break;
  }

 }
 Refresh;

}

fs_end:
 DCDel(dc);
 SettingsPop;
}

MarioMain;