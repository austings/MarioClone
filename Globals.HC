

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
static CDC* SPRITEBG= FramePtr("SPRITEBG");

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
#define JUMP_VEL -12

#define ACCEL       1
#define FRICTION    1
#define MAX_SPEED   6
#define TURN_ACCEL  1   // lower = longer skid
#define TURN_TIME   8
#define TILE_SIZE 32

class Mario{
 I64 x, y;
 I64 vx, vy;
 U8 dir;
 U8 state;
 I64 frame;
 I64 animTimer;
 I64 turnTimer;
 U8 turnDir;
} mario;

U8 keyL, keyR, keyJump;
I64 jumpBuffer = 0;
I64 grounded = 0;
U8 jumpHeld = 0;

class Level {
 I64 w, h;
 U8 *tiles;     // w*h
};
Level *clvl;
U0 InitMario()
{
 mario.x = 0;
 mario.y = 0;
 mario.vx = 0;
 mario.vy = 0;
 mario.dir = DIR_R;
 mario.state = ST_IDLE;
 mario.frame = 0;
 mario.animTimer = 0;
 mario.turnTimer = 0;
}

Bool IsSolidTile(I64 tx, I64 ty)
{
 if(tx < 0 || tx >= clvl->w || ty < 0 || ty >= clvl->h)
  return FALSE;

 return clvl->tiles[ty * clvl->w + tx] == 1;
}

I64 WorldToTile(I64 v)
{
 return v / TILE_SIZE;
}
