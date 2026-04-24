

static CDC* ONEL= FramePtr("1L");
static CDC* TWOL= FramePtr("2L");
static CDC* THREEL= FramePtr("3L");
static CDC* FOURL= FramePtr("4L");
static CDC* FIVEL= FramePtr("5R");
static CDC* SIXL= FramePtr("6L");
static CDC* ONER= FramePtr("1R");
static CDC* TWOR= FramePtr("2R");
static CDC* THREER= FramePtr("3R");
static CDC* FOURR= FramePtr("4R");
static CDC* FIVER= FramePtr("5L");
static CDC* SIXR= FramePtr("6R");
static CDC* FLOOR1= FramePtr("FLOOR1");
static CDC* FLOOR2= FramePtr("FLOOR2");
static CDC* FLOOR3= FramePtr("FLOOR3");
static CDC* Q1= FramePtr("Q1");
static CDC* Q2= FramePtr("Q2");
static CDC* Q3= FramePtr("Q3");
static CDC* Q4= FramePtr("Q4");
static CDC* C1= FramePtr("C1");
static CDC* C2= FramePtr("C2");
static CDC* C3= FramePtr("C3");
static CDC* C4= FramePtr("C4");
static CDC* C5= FramePtr("C5");
static CDC* SPRITEBG= FramePtr("SPRITEBG");
static CDC* BL1= FramePtr("BL1");
static CDC* BL2= FramePtr("BL2");
static CDC* BL3= FramePtr("BL3");
static CDC* BL4= FramePtr("BL4");
static CDC* BL5= FramePtr("BL5");
static CDC* BL6= FramePtr("BL6");
static CDC* BL7= FramePtr("BL7");
static CDC* BL8= FramePtr("BL8");
static CDC* BR1= FramePtr("BR1");
static CDC* BR2= FramePtr("BR2");
static CDC* BR3= FramePtr("BR3");
static CDC* BR4= FramePtr("BR4");
static CDC* BR5= FramePtr("BR5");
static CDC* BR6= FramePtr("BR6");
static CDC* BR7= FramePtr("BR7");
static CDC* BR8= FramePtr("BR8");
static CDC* MUSH= FramePtr("MUSH");


//Blocks
#define TILE_GROUND	1
#define TILE_BRICK	2
#define TILE_QUESTION	3
#define TILE_Q_MUSHRM	4

#define SCREEN_W 640   
#define CAMERA_MARGIN 320

// Direction
#define DIR_L 0
#define DIR_R 1

// States
#define ST_IDLE  0
#define ST_WALK  1
#define ST_TURN  2
#define ST_JUMP  3
#define ST_FALL  4

#define JUMP_BUFFER_FRAMES 6
#define GRAVITY 1
#define MAX_FALL 10
#define JUMP_VEL -18

#define ACCEL       .25
#define FRICTION    .25
#define MAX_SPEED   6
#define TURN_ACCEL  .85   // lower = longer skid
#define TURN_TIME   10
#define TILE_SIZE 32
#define MAX_COINS 32
#define MAX_MUSHRM 16
//Globals TODO: make object?
U8 keyL, keyR, keyJump;
I64 camX;
I64 jumpBuffer = 0;
I64 grounded = 0;
U8 jumpHeld = 0;
U8 jumpSoundActive = 0;

class Mario{
 F64 x, y;
 F64 vx, vy;
 U8 dir;
 U8 state;
 I64 frame;
 I64 isBig; // 0 = small, 1 = big, 2= flower
 I64 animTimer;
 I64 turnTimer;
 U8 turnDir;
 U8 transforming;     // NEW
 I64 transformTimer;  // NEW
} mario;

I64 MarioW()
{
 return 24; // keep width same for now (simpler)
}

I64 MarioH()
{
 if(mario.isBig) return 64; 
 return 32;
}

class Coin {
 I64 x, y;
 I64 vy;
 I64 timer;
 U8 active;
} coins[MAX_COINS];

class Mushroom {
 I64 x, y, targetY;
 I64 vx, vy;
 U8 active;
 U8 rising;
} mush[MAX_MUSHRM];



U0 InitMario()
{
 mario.x = 0;
 mario.y = 0;
 mario.vx = 0;
 mario.vy = 0;
 mario.dir = DIR_R;
 mario.state = ST_IDLE;
 mario.frame = 0;
 mario.animTimer = 0;
 mario.turnTimer = 0;
 mario.isBig = 0;
}

class Level {
 I64 w, h;
 U8 *tiles;     // w*h
 U8 *tileState;
 I8 *tileBounce;   // signed so we can go up/down
 I8 *tileBounceVel;   // velocity

};
Level *clvl;

Bool IsSolidTile(I64 tx, I64 ty)
{
 if(tx < 0 || tx >= clvl->w || ty < 0 || ty >= clvl->h)
  return FALSE;

 return clvl->tiles[ty * clvl->w + tx] >= 1;
}

Bool AABBOverlap(I64 x1, I64 y1, I64 w1, I64 h1,
                 I64 x2, I64 y2, I64 w2, I64 h2)
{
 return !(x1 + w1 <= x2 ||
          x1 >= x2 + w2 ||
          y1 + h1 <= y2 ||
          y1 >= y2 + h2);
}

I64 WorldToTile(I64 v)
{
 return v / TILE_SIZE;
}
