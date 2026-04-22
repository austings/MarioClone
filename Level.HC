U8 *ReadALine(U8 **fbuf) {
  U8 *en,*st=*fbuf,*buf;
  if(!*st) return NULL;
  if(en=StrFirstOcc(st,"\n")) {
    buf=MAlloc(en-st+2);
    MemCpy(buf,st,en-st+1);
    buf[en-st+1]=0;
    *fbuf=en+1;
    return buf;
  }
  *fbuf+=StrLen(st);
  return StrNew(st);
}
Bool StrEqual(U8 *a, U8 *b)
{
 I64 i = 0;

 while(a[i] && b[i]){
  if(a[i] != b[i])
   return FALSE;
  i++;
 }

 return (a[i] == 0 && b[i] == 0);
}
Bool StartsWith(U8 *str, U8 *prefix)
{
 I64 i = 0;
 while(prefix[i]){
  if(str[i] != prefix[i])
   return FALSE;
  i++;
 }
 return TRUE;
}
U8* SkipWhitespace(U8 *s)
{
 while(*s == ' ' || *s == '\t')
  s++;
 return s;
}

U8 CharToTile(U8 c)
{
 switch(c){
  case '#': return 1; // solid
  case '.': return 0; // empty
  case 'P': return 0; // player spawn (handled separately)
 }
 return 0;
}

Level *LoadLevel(U8 *path)
{
 U8 *fptr = FileRead(path);
 U8 *lnptr = fptr;
 U8 *ln;

 Level *lvl = MAlloc(sizeof(Level));
 lvl->w = 0;
 lvl->h = 0;
 lvl->tiles = NULL;

 I64 mode = 0; // 0=none,1=tiles,2=objects
 I64 x;
 I64 y = 0;

 while(ln = ReadALine(&lnptr))
 {
  if(*ln == 0){
   goto next;
  }

  // --- SIZE ---
  if(StartsWith(ln,"SIZE")){
   U8 tag[8], w[8], h[8];
   U8 *tptr=tag,*wptr=w,*hptr=h;

   StrScan(ln,"%s %s %s",&tptr,&wptr,&hptr);

   lvl->w = Str2I64(wptr);
   lvl->h = Str2I64(hptr);
   lvl->tiles = MAlloc(lvl->w * lvl->h);
   goto next;
  }

  // --- mode switches ---
  ln = SkipWhitespace(ln);

  if(StartsWith(ln,"TILES")){
   mode = 1;
   y = 0;
   goto next;
  }

  if(StartsWith(ln,"OBJECTS")){
   mode = 2;
   goto next;
  }

  // --- TILE PARSING ---
  if(mode == 1){
   for(x = 0; x < lvl->w && ln[x] != 0; x++){
    lvl->tiles[y * lvl->w + x] = CharToTile(ln[x]);

    if(ln[x] == 'P'){
     mario.x = x * 32;
     mario.y = y * 32;
    }
   }
   y++;
  }

  // --- OBJECT PARSING ---
  else if(mode == 2){
   U8 type[16], xs[8], ys[8];
   U8 *tagptr=type,*xptr=xs,*yptr=ys;

   StrScan(ln,"%s %s %s",&tptr,&xptr,&yptr);

   x = Str2I64(xptr);
   y = Str2I64(yptr);

   if(!StrEqual(type,"GOOMBA")){
    //SpawnGoomba(x, y);
   }
   else if(!StrEqual(type,"PIPE")){
    //SpawnPipe(x, y);
   }
  }

  next:
  Free(ln);
 }

 Free(fptr);
 return lvl;
}

