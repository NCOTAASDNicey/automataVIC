#importonce
// KERNAL routine aliases (VIC20)

.const  acptr=		$ffa5
.const  chkin=		$ffc6
.const  chkout=		$ffc9
.const  chrin=		$ffcf
.const  chrout=		$ffd2
.const  ciout=		$ffa8
.const  cint=		$ff81
.const  clall=		$ffe7
.const  close=		$ffc3
.const  clrchn=		$ffcc
.const  getin=		$ffe4
.const  iobase=		$fff3
.const  ioinit=		$ff84
.const  listen=		$ffb1
.const  load=		$ffd5
.const  membot=		$ff9c
.const  memtop=		$ff99
.const  open=		$ffc0
.const  plot=		$fff0
.const  ramtas=		$ff87
.const  rdtim=		$ffde
.const  readst=		$ffb7
.const  restor=		$ff8a
.const  save=		$ffd8
.const  scnkey=		$ff9f
.const  screen=		$ffed
.const  second=		$ff93
.const  setlfs=		$ffba
.const  setmsg=		$ff90
.const  setnam=		$ffbd
.const  settim=		$ffdb
.const  settmo=		$ffa2
.const  stop=		$ffe1
.const  talk=		$ffb4
.const  tksa=		$ff96
.const  udtim=		$ffea
.const  unlsn=		$ffae
.const  untlk=		$ffab
.const  vector=		$ff8d

.const basic_random= $e097

// Character codes for the colors.

//VIC Registers
.const  VIC_h_center= $9000
.const  VIC_v_center= $9001
.const  VIC_columns=  $9002
.const  VIC_rows=     $9003
.const  VIC_raster=   $9004
.const  VIC_char_mem= $9005
.const  VIC_h_pen=    $9006
.const  VIC_v_pen=    $9007
.const  VIC_x_pad=    $9008
.const  VIC_y_pad=    $9009
.const  VIC_osc_low=  $900a
.const  VIC_osc_med=  $900b
.const  VIC_osc_high= $900c
.const  VIC_noise=    $900d
.const  VIC_volume=   $900e
.const  VIC_screen=   $900f

// I/O
.const  VIA1_ddr=   	$9113
.const  VIA1_output=  $9111
.const  VIA2_ddr=   	$9122
.const  VIA2_output=  $9120
.const  JOY_SW0=  4
.const  JOY_SW1=  8
.const  JOY_SW2=  16
.const  JOY_SW4=  32
.const  JOY_SW3=  128


.const  screen_mem=       $1e00
.const  screen_mem_hi=    $1000
.const  colour_mem=       $9600
.const  colour_mem_hi=    $9400

.const  X_CHARS=   22
.const  Y_CHARS=   23

.const  KEY_CSR_UP= 145
.const  KEY_CSR_DOWN= 17
.const  KEY_CSR_LEFT= 157
.const  KEY_CSR_RIGHT= 29
.const  KEY_SPACE= 32
.const  KEY_RETURN= 13
.const  KEY_ESC= 3



.const  black=        0
.const  white=        1
.const  red=          2
.const  cyan=         3
.const  purple=       4
.const  green=        5
.const  blue=         6
.const  yellow=       7
.const  orange=       8
.const  lt_orange=    9
.const  pink=         10
.const  lt_cyan=      11
.const  lt_purple=    12
.const  lt_green=     13
.const  lt_blue=      14
.const  lt_yellow=    15

.const FPA1_exponent= $61
.const FPA1_mantissa= $62
.const FPA1_sign= $66

.const  zero_page_rs_232=   247

.const  zero_page_free1=    251
.const  zero_page_free2=    252
.const  zero_page_free3=    253
.const  zero_page_free4=    254
.const  chrout_colour=      $286

.const SAREG=$30C
.const SXREG=$30D
.const SYREG=$30E