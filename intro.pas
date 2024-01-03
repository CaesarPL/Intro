uses crt, mpt, fastgraph;

const	star_max = 64;
	star_speed = 1;

	w = 160;
	h = 96;
	
	cx = w div 2;
	cy = h div 2;
	
	ds = 3;

	mpt_player = $a000;
	mpt_modul = $4000;

var
	msx: TMPT;
//	i: integer;
//	x, y: integer;
	star_x, star_y, px, py: array [0..star_max-1] of byte;
	star_s: array [0..star_max-1] of shortint;

	x, y, i: byte;

var
  PORTB  : byte absolute $D301;
  NMIEN  : byte absolute $D40E;
  DLIST  : word absolute $D402;
  NMIVEC : word absolute $FFFA;

  counter        : byte absolute 0;
  vbivec, vdslst : ^word;
  offrti         : word;

procedure VanishingSquare(x,y,c,cb: byte);
begin
	SetColor(c);
	fRectangle(x,y,x+9,y+9);
	pause(5);
	fRectangle(x+1,y+1,x+8,y+8);
	pause(5);

	SetColor(cb);
	fRectangle(x,y,x+9,y+9);
	pause(5);
	fRectangle(x+1,y+1,x+8,y+8);
	pause(5);
end;

procedure VanishingTriangle(x,y,c,cb: byte);
begin
	SetColor(c);
	fLine(x,y,x-9,y+9);
	fLine(x,y,x+9,y+9);
	fLine(x-9,y+9,x+9,y+9);
	pause(5);
	fLine(x+1,y+1,x-8,y+8);
	fLine(x+1,y+1,x+8,y+8);
	fLine(x-8,y+8,x+8,y+8);
	pause(5);

	SetColor(cb);
	fLine(x,y,x-9,y+9);
	fLine(x,y,x+9,y+9);
	fLine(x-9,y+9,x+9,y+9);
	pause(5);
	fLine(x+1,y+1,x-8,y+8);
	fLine(x+1,y+1,x+8,y+8);
	fLine(x-8,y+8,x+8,y+8);
	pause(5);
end;

procedure nmi; assembler; interrupt;
asm
{
      bit NMIST \ bpl vbi   ; check kind of interrupt
      jmp off               ; VDSLST
vbi:  inc RTCLOK+2
      jmp off               ; VBIVEC
off:
};
end;

procedure vbi; interrupt;
begin
  asm { phr };
  inc(counter);
  asm { plr };
end;

procedure systemOff;
begin
  asm { sei };
  vdslst := pointer(word(@nmi) + 6);
  vbivec := pointer(word(@nmi) + 11);
  offrti := word(@nmi) + 13;
  NMIEN := 0; PORTB := $FE; NMIVEC := word(@nmi); NMIEN := $40;
end;

procedure init;
begin
	randomize;

	x:=w shr 1;
	y:=h shr 1;

	for i:=0 to star_max-1 do begin
		star_x[i]:=random(0);
		star_y[i]:=random(0);
		star_s[i]:=random(0);
	end;
  
end;

procedure anim;

function test: Boolean;
begin

 Result := ((px[i]<cx-ds) or (px[i]>cx+ds)) and ((py[i]<cy-ds) or (py[i]>cy+ds));
 
end; 

begin

  for i:=0 to star_max-1 do begin

    if test then begin

    SetColor(0);
    PutPixel(px[i], py[i]); 
    
    end;
  
    dec(star_s[i], star_speed);
    if (star_s[i] < 0) then star_s[i]:=random(0) and $3f;

    px[i] := x+(star_x[i] div star_s[i]);
    py[i] := y+(star_y[i] div star_s[i]);
    
    if test then begin

    SetColor(1);
    PutPixel(px[i], py[i]);

    end;
    
  end;

end;

procedure vbl;interrupt;
begin
asm { phr ; store registers };
    msx.Play;
asm {
    plr ; restore registers
    jmp $E462 ; jump to system VBL handler
    };
end;

{$r 'mpt_play.rc'}

begin
//  systemOff;
//  pause(100);
//  vbivec^ := word(@vbi);

	msx.player:=pointer(mpt_player);
	msx.modul:=pointer(mpt_modul);

	
	msx.init;
    SetIntVec(iVBL,@vbl);

//Ustawiam tryb graficzny na 
	InitGraph(7+16);
//	InitGraph(11);
	SetColor(1);
	init;

	  VanishingSquare(1,1,1,0);
	  pause(5);
	  VanishingSquare(11,11,1,0);
	  pause(5);
	  VanishingSquare(21,21,1,0);
	  pause(5);
	  VanishingSquare(31,31,1,0);
	  pause(5);

//	  VanishingTriangle(1,1,1,0);
//	  pause(5);
	  VanishingTriangle(11,11,1,0);
	  pause(5);
	  VanishingTriangle(21,21,1,0);
	  pause(5);
	  VanishingTriangle(31,31,1,0);
	  pause(5);

	repeat
//		pause;

//	msx.play;

//	for y := 1 to 100 do 
//	begin
	  
//	  SetColor($01);
//	end;

	anim; 

	until keypressed;

	msx.stop;

end.

