function romanize(txtin) {
	var outch;
	var newtxt;
	var txtout="";
	
	txtin=txtin.replace(/(\S)(\u0393)(\s)/g,"$1N$3").replace(/(\S)(\u03B3)(\s)/g,"$1n$3");
	for(var t=0;t<txtin.length;t++) {
		switch(txtin.charCodeAt(t)) {
			case 0x0314:
				outch="h";
				break;
			case 0x0315:
				outch="";
				break;
			case 0x0342:
				outch=String.fromCharCode(0x0302);
				break;
			case 0x0343:
				outch = "";
				break;
			case 0x0344:
				outch = String.fromCharCode(0x0308) + String.fromCharCode(0x0301);
				break;
			case 0x0345:
				outch = "i";
				break;
			case 0x0370:
				outch = "H";
				break;
			case 0x0371:
				outch = "h";
				break;
			case 0x0372:
				outch = "Ts";
				break;
			case 0x0373:
				outch = "ts";
				break;
			case 0x0374:
			case 0x0375:
				outch = "";
				break;
			case 0x0376:
				outch = "W";
				break;
			case 0x0377:
				outch = "w";
				break;
			case 0x037A:
				outch = "i";
				break;
			case 0x037B:
			case 0x037C:
			case 0x037D:
				outch = "s";
				break;
			case 0x037E:
				outch = "?";
				break;
			case 0x0384:
				outch = String.fromCharCode(0x0B4);
				break;
			case 0x0385:
				outch = String.fromCharCode(0x0A8) + String.fromCharCode(0x0301);
				break;
			case 0x0386:
				outch = String.fromCharCode(0x0C1);
				break;
			case 0x0387:
				outch = ";";
				break;
			case 0x0388:
				outch = String.fromCharCode(0x0C9);
				break;
			case 0x0389:
				outch = String.fromCharCode(0x1E16);
				break;
			case 0x038A:
				outch = String.fromCharCode(0x0CD);
				break;
			case 0x038C:
				outch = String.fromCharCode(0x0D3);
				break;
			case 0x038E:
				outch = String.fromCharCode(0x0DA);
				break;
			case 0x038F:
				outch = String.fromCharCode(0x1E52);
				break;
			case 0x0390:
				outch = String.fromCharCode(0x1E2F);
				break;
			case 0x0391:
				outch = "A";
				break;
			case 0x0392:
				outch = "B";
				break;
			case 0x0393:
				outch = "G";
				break;
			case 0x0394:
				outch = "D";
				break;
			case 0x0395:
				outch = "E";
				break;
			case 0x0396:
				outch = "Z";
				break;
			case 0x0397:
				outch = String.fromCharCode(0x112);
				break;
			case 0x0398:
				outch = "Th";
				break;
			case 0x0399:
				outch = "I";
				break;
			case 0x039A:
				outch = "K";
				break;
			case 0x039B:
				outch = "L";
				break;
			case 0x039C:
				outch = "M";
				break;
			case 0x039D:
				outch = "N";
				break;
			case 0x039E:
				outch = "X";
				break;
			case 0x039F:
				outch = "O";
				break;
			case 0x03A0:
				outch = "P";
				break;
			case 0x03A1:
				outch = "R";
				break;
			case 0x03A3:
				outch = "S";
				break;
			case 0x03A4:
				outch = "T";
				break;
			case 0x03A5:
				outch = "U";
				break;
			case 0x03A6:
				outch = "Ph";
				break;
			case 0x03A7:
				outch = "Kh";
				break;
			case 0x03A8:
				outch = "Ps";
				break;
			case 0x03A9:
				outch = String.fromCharCode(0x14C);
				break;
			case 0x03AA:
				outch = String.fromCharCode(0x0CF);
				break;
			case 0x03AB:
				outch = String.fromCharCode(0x0DC);
				break;
			case 0x03AC:
				outch = String.fromCharCode(0x0E1);
				break;
			case 0x03AD:
				outch = String.fromCharCode(0x0E9);
				break;
			case 0x03AE:
				outch = String.fromCharCode(0x1E17);
				break;
			case 0x03AF:
				outch = String.fromCharCode(0x0ED);
				break;
			case 0x03B0:
				outch = String.fromCharCode(0x1D8);
				break;
			case 0x03B1:
				outch = "a";
				break;
			case 0x03B2:
				outch = "b";
				break;
			case 0x03B3:
				outch = "g";
				break;
			case 0x03B4:
				outch = "d";
				break;
			case 0x03B5:
				outch = "e";
				break;
			case 0x03B6:
				outch = "z";
				break;
			case 0x03B7:
				outch = String.fromCharCode(0x113);
				break;
			case 0x03B8:
				outch = "th";
				break;
			case 0x03B9:
				outch = "i";
				break;
			case 0x03BA:
				outch = "k";
				break;
			case 0x03BB:
				outch = "l";
				break;
			case 0x03BC:
				outch = "m";
				break;
			case 0x03BD:
				outch = "n";
				break;
			case 0x03BE:
				outch = "x";
				break;
			case 0x03BF:
				outch = "o";
				break;
			case 0x03C0:
				outch = "p";
				break;
			case 0x03C1:
				outch = "r";
				break;
			case 0x03C2:
			case 0x03C3:
				outch = "s";
				break;
			case 0x03C4:
				outch = "t";
				break;
			case 0x03C5:
				outch = "u";
				break;
			case 0x03C6:
				outch = "ph";
				break;
			case 0x03C7:
				outch = "kh";
				break;
			case 0x03C8:
				outch = "ps";
				break;
			case 0x03C9:
				outch = String.fromCharCode(0x14D);
				break;
			case 0x03CA:
				outch = String.fromCharCode(0x0EF);
				break;
			case 0x03CB:
				outch = String.fromCharCode(0x0FC);
				break;
			case 0x03CC:
				outch = String.fromCharCode(0x0F3);
				break;
			case 0x03CD:
				outch = String.fromCharCode(0x0FA);
				break;
			case 0x03CE:
				outch = String.fromCharCode(0x1E53);
				break;
			case 0x03CF:
				outch = "&";
				break;
			case 0x03D0:
				outch = "b";
				break;
			case 0x03D1:
				outch = "th";
				break;
			case 0x03D2:
				outch = "U";
				break;
			case 0x03D3:
				outch = String.fromCharCode(0x0DA);
				break;
			case 0x03D4:
				outch = String.fromCharCode(0x0DC);
				break;
			case 0x03D5:
				outch = "ph";
				break;
			case 0x03D6:
				outch = "p";
				break;
			case 0x03D7:
				outch = "&";
				break;
			case 0x03D8:
				outch = "Q";
				break;
			case 0x03D9:
				outch = "q";
				break;
			case 0x03DA:
				outch = "St";
				break;
			case 0x03DB:
				outch = "st";
				break;
			case 0x03DC:
				outch = "W";
				break;
			case 0x03DD:
				outch = "w";
				break;
			case 0x03DE:
				outch = "Q";
				break;
			case 0x03DF:
				outch = "q";
				break;
			case 0x03E0:
				outch = "Ts";
				break;
			case 0x03E1:
				outch = "ts";
				break;
			case 0x03F0:
				outch = "k";
				break;
			case 0x03F1:
				outch = "r";
				break;
			case 0x03F2:
				outch = "s";
				break;
			case 0x03F3:
				outch = "y";
				break;
			case 0x03F4:
				outch = "Th";
				break;
			case 0x03F5:
				outch = "e";
				break;
			case 0x03F6:
				outch = String.fromCharCode(0x0258);
				break;
			case 0x03F7:
				outch = "Sh";
				break;
			case 0x03F8:
				outch = "sh";
				break;
			case 0x03F9:
			case 0x03FA:
				outch = "S";
				break;
			case 0x03FB:
				outch = "s";
				break;
			case 0x03FC:
				outch = String.fromCharCode(0x024D);
				break;
			case 0x03FD:
			case 0x03FE:
			case 0x03FF:
				outch = "S";
				break;
			case 0x1F00:
				outch = "a";
				break;
			case 0x1F01:
				outch = "ha";
				break;
			case 0x1F02:
				outch = String.fromCharCode(0x0E0);
				break;
			case 0x1F03:
				outch = "h" + String.fromCharCode(0x0E0);
				break;
			case 0x1F04:
				outch = String.fromCharCode(0x0E1);
				break;
			case 0x1F05:
				outch = "h" + String.fromCharCode(0x0E1);
				break;
			case 0x1F06:
				outch = String.fromCharCode(0x0E2);
				break;
			case 0x1F07:
				outch = "h" + String.fromCharCode(0x0E2);
				break;
			case 0x1F08:
				outch = "A";
				break;
			case 0x1F09:
				outch = "Ha";
				break;
			case 0x1F0A:
				outch = String.fromCharCode(0x0C0);
				break;
			case 0x1F0B:
				outch = "H" + String.fromCharCode(0x0E0);
				break;
			case 0x1F0C:
				outch = String.fromCharCode(0x0C1);
				break;
			case 0x1F0D:
				outch = "H" + String.fromCharCode(0x0E1);
				break;
			case 0x1F0E:
				outch = String.fromCharCode(0x0C2);
				break;
			case 0x1F0F:
				outch = "H" + String.fromCharCode(0x0E2);
				break;
			case 0x1F10:
				outch = "e";
				break;
			case 0x1F11:
				outch = "he";
				break;
			case 0x1F12:
				outch = String.fromCharCode(0x0E8);
				break;
			case 0x1F13:
				outch = "h" + String.fromCharCode(0x0E8);
				break;
			case 0x1F14:
				outch = String.fromCharCode(0x0E9);
				break;
			case 0x1F15:
				outch = "h" + String.fromCharCode(0x0E9);
				break;
			case 0x1F18:
				outch = "E";
				break;
			case 0x1F19:
				outch = "He";
				break;
			case 0x1F1A:
				outch = String.fromCharCode(0x0C8);
				break;
			case 0x1F1B:
				outch = "H" + String.fromCharCode(0x0E8);
				break;
			case 0x1F1C:
				outch = String.fromCharCode(0x0C9);
				break;
			case 0x1F1D:
				outch = "H" + String.fromCharCode(0x0E9);
				break;
			case 0x1F20:
				outch = String.fromCharCode(0x113);
				break;
			case 0x1F21:
				outch = "h" + String.fromCharCode(0x113);
				break;
			case 0x1F22:
				outch = String.fromCharCode(0x1E15);
				break;
			case 0x1F23:
				outch = "h" + String.fromCharCode(0x1E15);
				break;
			case 0x1F24:
				outch = String.fromCharCode(0x1E17);
				break;
			case 0x1F25:
				outch = "h" + String.fromCharCode(0x1E17);
				break;
			case 0x1F26:
				outch = String.fromCharCode(0x0EA);
				break;
			case 0x1F27:
				outch = "h" + String.fromCharCode(0x0EA);
				break;
			case 0x1F28:
				outch = String.fromCharCode(0x112);
				break;
			case 0x1F29:
				outch = "H" + String.fromCharCode(0x113);
				break;
			case 0x1F2A:
				outch = String.fromCharCode(0x1E14);
				break;
			case 0x1F2B:
				outch = "H" + String.fromCharCode(0x1E15);
				break;
			case 0x1F2C:
				outch = String.fromCharCode(0x1E16);
				break;
			case 0x1F2D:
				outch = "H" + String.fromCharCode(0x1E17);
				break;
			case 0x1F2E:
				outch = String.fromCharCode(0x0CA);
				break;
			case 0x1F2F:
				outch = "H" + String.fromCharCode(0x0EA);
				break;
			case 0x1F30:
				outch = "i";
				break;
			case 0x1F31:
				outch = "hi";
				break;
			case 0x1F32:
				outch = String.fromCharCode(0x0EC);
				break;
			case 0x1F33:
				outch = "h" + String.fromCharCode(0x0EC);
				break;
			case 0x1F34:
				outch = String.fromCharCode(0x0ED);
				break;
			case 0x1F35:
				outch = "h" + String.fromCharCode(0x0ED);
				break;
			case 0x1F36:
				outch = String.fromCharCode(0x0EE);
				break;
			case 0x1F37:
				outch = "h" + String.fromCharCode(0x0EE);
				break;
			case 0x1F38:
				outch = "I";
				break;
			case 0x1F39:
				outch = "Hi";
				break;
			case 0x1F3A:
				outch = String.fromCharCode(0x0CC);
				break;
			case 0x1F3B:
				outch = "H" + String.fromCharCode(0x0EC);
				break;
			case 0x1F3C:
				outch = String.fromCharCode(0x0CD);
				break;
			case 0x1F3D:
				outch = "H" + String.fromCharCode(0x0ED);
				break;
			case 0x1F3E:
				outch = String.fromCharCode(0x0CE);
				break;
			case 0x1F3F:
				outch = "H" + String.fromCharCode(0x0EE);
				break;
			case 0x1F40:
				outch = "o";
				break;
			case 0x1F41:
				outch = "ho";
				break;
			case 0x1F42:
				outch = String.fromCharCode(0x0F2);
				break;
			case 0x1F43:
				outch = "h" + String.fromCharCode(0x0F2);
				break;
			case 0x1F44:
				outch = String.fromCharCode(0x0F3);
				break;
			case 0x1F45:
				outch = "h" + String.fromCharCode(0x0F3);
				break;
			case 0x1F48:
				outch = "O";
				break;
			case 0x1F49:
				outch = "Ho";
				break;
			case 0x1F4A:
				outch = String.fromCharCode(0x0D2);
				break;
			case 0x1F4B:
				outch = "H" + String.fromCharCode(0x0F2);
				break;
			case 0x1F4C:
				outch = String.fromCharCode(0x0D3);
				break;
			case 0x1F4D:
				outch = "H" + String.fromCharCode(0x0F3);
				break;
			case 0x1F50:
				outch = "u";
				break;
			case 0x1F51:
				outch = "hu";
				break;
			case 0x1F52:
				outch = String.fromCharCode(0x0F9);
				break;
			case 0x1F53:
				outch = "h" + String.fromCharCode(0x0F9);
				break;
			case 0x1F54:
				outch = String.fromCharCode(0x0FA);
				break;
			case 0x1F55:
				outch = "h" + String.fromCharCode(0x0FA);
				break;
			case 0x1F56:
				outch = String.fromCharCode(0x0FB);
				break;
			case 0x1F57:
				outch = "h" + String.fromCharCode(0x0FB);
				break;
			case 0x1F59:
				outch = "Hu";
				break;
			case 0x1F5B:
				outch = "H" + String.fromCharCode(0x0F9);
				break;
			case 0x1F5D:
				outch = "H" + String.fromCharCode(0x0FA);
				break;
			case 0x1F5F:
				outch = "H" + String.fromCharCode(0x0FB);
				break;
			case 0x1F60:
				outch = String.fromCharCode(0x14D);
				break;
			case 0x1F61:
				outch = "h" + String.fromCharCode(0x14D);
				break;
			case 0x1F62:
				outch = String.fromCharCode(0x1E51);
				break;
			case 0x1F63:
				outch = "h" + String.fromCharCode(0x1E51);
				break;
			case 0x1F64:
				outch = String.fromCharCode(0x1E53);
				break;
			case 0x1F65:
				outch = "h" + String.fromCharCode(0x1E53);
				break;
			case 0x1F66:
				outch = String.fromCharCode(0x0F4);
				break;
			case 0x1F67:
				outch = "h" + String.fromCharCode(0x0F4);
				break;
			case 0x1F68:
				outch = String.fromCharCode(0x14C);
				break;
			case 0x1F69:
				outch = "H" + String.fromCharCode(0x14D);
				break;
			case 0x1F6A:
				outch = String.fromCharCode(0x1E50);
				break;
			case 0x1F6B:
				outch = "H" + String.fromCharCode(0x1E51);
				break;
			case 0x1F6C:
				outch = String.fromCharCode(0x1E52);
				break;
			case 0x1F6D:
				outch = "H" + String.fromCharCode(0x1E53);
				break;
			case 0x1F6E:
				outch = String.fromCharCode(0x0D4);
				break;
			case 0x1F6F:
				outch = "H" + String.fromCharCode(0x0F4);
				break;
			case 0x1F70:
				outch = String.fromCharCode(0x0E0);
				break;
			case 0x1F71:
				outch = String.fromCharCode(0x0E1);
				break;
			case 0x1F72:
				outch = String.fromCharCode(0x0E8);
				break;
			case 0x1F73:
				outch = String.fromCharCode(0x0E9);
				break;
			case 0x1F74:
				outch = String.fromCharCode(0x1E15);
				break;
			case 0x1F75:
				outch = String.fromCharCode(0x1E17);
				break;
			case 0x1F76:
				outch = String.fromCharCode(0x0EC);
				break;
			case 0x1F77:
				outch = String.fromCharCode(0x0ED);
				break;
			case 0x1F78:
				outch = String.fromCharCode(0x0F2);
				break;
			case 0x1F79:
				outch = String.fromCharCode(0x0F3);
				break;
			case 0x1F7A:
				outch = String.fromCharCode(0x0F9);
				break;
			case 0x1F7B:
				outch = String.fromCharCode(0x0FA);
				break;
			case 0x1F7C:
				outch = String.fromCharCode(0x1E51);
				break;
			case 0x1F7D:
				outch = String.fromCharCode(0x1E53);
				break;
			case 0x1F80:
				outch = String.fromCharCode(0x101) + "i";
				break;
			case 0x1F81:
				outch = "h" + String.fromCharCode(0x101) + "i";
				break;
			case 0x1F82:
				outch = String.fromCharCode(0x101) + String.fromCharCode(0x0300) + "i";
				break;
			case 0x1F83:
				outch = "h" + String.fromCharCode(0x101) + String.fromCharCode(0x0300) + "i";
				break;
			case 0x1F84:
				outch = String.fromCharCode(0x101) + String.fromCharCode(0x0301) + "i";
				break;
			case 0x1F85:
				outch = "h" + String.fromCharCode(0x101) + String.fromCharCode(0x0300) + "i";
				break;
			case 0x1F86:
				outch = String.fromCharCode(0x0E2) + "i";
				break;
			case 0x1F87:
				outch = "h" + String.fromCharCode(0x0E2) + "i";
				break;
			case 0x1F88:
				outch = String.fromCharCode(0x100) + "i";
				break;
			case 0x1F89:
				outch = "H" + String.fromCharCode(0x101) + "i";
				break;
			case 0x1F8A:
				outch = String.fromCharCode(0x100) + String.fromCharCode(0x0300) + "i";
				break;
			case 0x1F8B:
				outch = "H" + String.fromCharCode(0x101) + String.fromCharCode(0x0300) + "i";
				break;
			case 0x1F8C:
				outch = String.fromCharCode(0x100) + String.fromCharCode(0x0301) + "i";
				break;
			case 0x1F8D:
				outch = "H" + String.fromCharCode(0x101) + String.fromCharCode(0x0301) + "i";
				break;
			case 0x1F8E:
				outch = String.fromCharCode(0x0C2) + "i";
				break;
			case 0x1F8F:
				outch = "H" + String.fromCharCode(0x0E2) + "i";
				break;
			case 0x1F90:
				outch = String.fromCharCode(0x113) + "i";
				break;
			case 0x1F91:
				outch = "h" + String.fromCharCode(0x113) + "i";
				break;
			case 0x1F92:
				outch = String.fromCharCode(0x1E15) + "i";
				break;
			case 0x1F93:
				outch = "h" + String.fromCharCode(0x1E15) + "i";
				break;
			case 0x1F94:
				outch = String.fromCharCode(0x1E17) + "i";
				break;
			case 0x1F95:
				outch = "h" + String.fromCharCode(0x1E17) + "i";
				break;
			case 0x1F96:
				outch = String.fromCharCode(0x0EA) + "i";
				break;
			case 0x1F97:
				outch = "h" + String.fromCharCode(0x0EA) + "i";
				break;
			case 0x1F98:
				outch = String.fromCharCode(0x112);
				break;
			case 0x1F99:
				outch = "H" + String.fromCharCode(0x113) + "i";
				break;
			case 0x1F9A:
				outch = String.fromCharCode(0x1E14) + "i";
				break;
			case 0x1F9B:
				outch = "H" + String.fromCharCode(0x1E15) + "i";
				break;
			case 0x1F9C:
				outch = String.fromCharCode(0x1E16) + "i";
				break;
			case 0x1F9D:
				outch = "H" + String.fromCharCode(0x1E17) + "i";
				break;
			case 0x1F9E:
				outch = String.fromCharCode(0x0CA) + "i";
				break;
			case 0x1F9F:
				outch = "H" + String.fromCharCode(0x0EA) + "i";
				break;
			case 0x1FA0:
				outch = String.fromCharCode(0x14D) + "i";
				break;
			case 0x1FA1:
				outch = "h" + String.fromCharCode(0x14D) + "i";
				break;
			case 0x1FA2:
				outch = String.fromCharCode(0x1E51) + "i";
				break;
			case 0x1FA3:
				outch = "h" + String.fromCharCode(0x1E51) + "i";
				break;
			case 0x1FA4:
				outch = String.fromCharCode(0x1E53) + "i";
				break;
			case 0x1FA5:
				outch = "h" + String.fromCharCode(0x1E53) + "i";
				break;
			case 0x1FA6:
				outch = String.fromCharCode(0x0F4) + "i";
				break;
			case 0x1FA7:
				outch = "h" + String.fromCharCode(0x0F4) + "i";
				break;
			case 0x1FA8:
				outch = String.fromCharCode(0x14C) + "i";
				break;
			case 0x1FA9:
				outch = "H" + String.fromCharCode(0x14D) + "i";
				break;
			case 0x1FAA:
				outch = String.fromCharCode(0x1E50) + "i";
				break;
			case 0x1FAB:
				outch = "H" + String.fromCharCode(0x1E51) + "i";
				break;
			case 0x1FAC:
				outch = String.fromCharCode(0x1E52) + "i";
				break;
			case 0x1FAD:
				outch = "H" + String.fromCharCode(0x1E53) + "i";
				break;
			case 0x1FAE:
				outch = String.fromCharCode(0x0D4) + "i";
				break;
			case 0x1FAF:
				outch = "H" + String.fromCharCode(0x0F4) + "i";
				break;
			case 0x1FB0:
				outch = String.fromCharCode(0x103);
				break;
			case 0x1FB1:
				outch = String.fromCharCode(0x101);
				break;
			case 0x1FB2:
				outch = String.fromCharCode(0x101) + String.fromCharCode(0x0300) + "i";
				break;
			case 0x1FB3:
				outch = String.fromCharCode(0x101) + "i";
				break;
			case 0x1FB4:
				outch = String.fromCharCode(0x101) + String.fromCharCode(0x0301) + "i";
				break;
			case 0x1FB6:
				outch = String.fromCharCode(0x0E2);
				break;
			case 0x1FB7:
				outch = String.fromCharCode(0x0E2) + "i";
				break;
			case 0x1FB8:
				outch = String.fromCharCode(0x102);
				break;
			case 0x1FB9:
				outch = String.fromCharCode(0x100);
				break;
			case 0x1FBA:
				outch = String.fromCharCode(0x0C0);
				break;
			case 0x1FBB:
				outch = String.fromCharCode(0x0C1);
				break;
			case 0x1FBC:
				outch = String.fromCharCode(0x100) + "i";
				break;
			case 0x1FBD:
				outch = String.fromCharCode(0x2019);
				break;
			case 0x1FBE:
				outch = "i";
				break;
			case 0x1FBF:
				outch = "";
				break;
			case 0x1FC0:
				outch = String.fromCharCode(0x02C6);
				break;
			case 0x1FC1:
				outch = String.fromCharCode(0x0A8) + String.fromCharCode(0x0302);
				break;
			case 0x1FC2:
				outch = String.fromCharCode(0x1E15) + "i";
				break;
			case 0x1FC3:
				outch = String.fromCharCode(0x113) + "i";
				break;
			case 0x1FC4:
				outch = String.fromCharCode(0x1E17) + "i";
				break;
			case 0x1FC6:
				outch = String.fromCharCode(0x0EA);
				break;
			case 0x1FC7:
				outch = String.fromCharCode(0x0EA) + "i";
				break;
			case 0x1FC8:
				outch = String.fromCharCode(0x0C8);
				break;
			case 0x1FC9:
				outch = String.fromCharCode(0x0C9);
				break;
			case 0x1FCA:
				outch = String.fromCharCode(0x1E14);
				break;
			case 0x1FCB:
				outch = String.fromCharCode(0x1E16);
				break;
			case 0x1FCC:
				outch = String.fromCharCode(0x112) + "i";
				break;
			case 0x1FCD:
				outch = String.fromCharCode(0x060);
				break;
			case 0x1FCE:
				outch = String.fromCharCode(0x0B4);
				break;
			case 0x1FCF:
				outch = String.fromCharCode(0x02C6);
				break;
			case 0x1FD0:
				outch = String.fromCharCode(0x12D);
				break;
			case 0x1FD1:
				outch = String.fromCharCode(0x12B);
				break;
			case 0x1FD2:
				outch = String.fromCharCode(0x0EF) + String.fromCharCode(0x0300);
				break;
			case 0x1FD3:
				outch = String.fromCharCode(0x0EF) + String.fromCharCode(0x0301);
				break;
			case 0x1FD6:
				outch = String.fromCharCode(0x0EE);
				break;
			case 0x1FD7:
				outch = String.fromCharCode(0x0EF) + String.fromCharCode(0x0302);
				break;
			case 0x1FD8:
				outch = String.fromCharCode(0x12C);
				break;
			case 0x1FD9:
				outch = String.fromCharCode(0x12A);
				break;
			case 0x1FDA:
				outch = String.fromCharCode(0x0CC);
				break;
			case 0x1FDB:
				outch = String.fromCharCode(0x0CD);
				break;
			case 0x1FDD:
				outch = "h" + String.fromCharCode(0x060);
				break;
			case 0x1FDE:
				outch = "h" + String.fromCharCode(0x0B4);
				break;
			case 0x1FDF:
				outch = "h" + String.fromCharCode(0x02C6);
				break;
			case 0x1FE0:
				outch = String.fromCharCode(0x16D);
				break;
			case 0x1FE1:
				outch = String.fromCharCode(0x16B);
				break;
			case 0x1FE2:
				outch = String.fromCharCode(0x1DC);
				break;
			case 0x1FE3:
				outch = String.fromCharCode(0x1D8);
				break;
			case 0x1FE4:
				outch = "r";
				break;
			case 0x1FE5:
				outch = "rh";
				break;
			case 0x1FE6:
				outch = String.fromCharCode(0x0FB);
				break;
			case 0x1FE7:
				outch = String.fromCharCode(0x0FC) + String.fromCharCode(0x0302);
				break;
			case 0x1FE8:
				outch = String.fromCharCode(0x16C);
				break;
			case 0x1FE9:
				outch = String.fromCharCode(0x16A);
				break;
			case 0x1FEA:
				outch = String.fromCharCode(0x0D9);
				break;
			case 0x1FEB:
				outch = String.fromCharCode(0x0DA);
				break;
			case 0x1FEC:
				outch = "Rh";
				break;
			case 0x1FED:
				outch = String.fromCharCode(0x0A8) + String.fromCharCode(0x0300);
				break;
			case 0x1FEE:
				outch = String.fromCharCode(0x0A8) + String.fromCharCode(0x0301);
				break;
			case 0x1FEF:
				outch = String.fromCharCode(0x060);
				break;
			case 0x1FF2:
				outch = String.fromCharCode(0x1E51) + "i";
				break;
			case 0x1FF3:
				outch = String.fromCharCode(0x14D) + "i";
				break;
			case 0x1FF4:
				outch = String.fromCharCode(0x1E53) + "i";
				break;
			case 0x1FF6:
				outch = String.fromCharCode(0x0F4);
				break;
			case 0x1FF7:
				outch = String.fromCharCode(0x0F4) + "i";
				break;
			case 0x1FF8:
				outch = String.fromCharCode(0x0D2);
				break;
			case 0x1FF9:
				outch = String.fromCharCode(0x0D3);
				break;
			case 0x1FFA:
				outch = String.fromCharCode(0x1E50);
				break;
			case 0x1FFB:
				outch = String.fromCharCode(0x1E52);
				break;
			case 0x1FFC:
				outch = String.fromCharCode(0x14C) + "i";
				break;
			case 0x1FFD:
				outch = String.fromCharCode(0x0B4);
				break;
			case 0x1FFE:
				outch = "h";
				break;
			default:
				outch = txtin.charAt(t)
		}
		if(txtin.charCodeAt(t)>0xFF) {
			switch(outch.charAt(0)) {
				case "H":
				case "h":
					if(txtout.length==1) {
						newtxt=" " + txtout.substring(txtout.length-1);
					}
					else {
						newtxt=txtout.substring(txtout.length-2);
					}
					if(newtxt.charCodeAt(0)<0x41 && newtxt.charCodeAt(1)>=0x41 && (newtxt.charCodeAt(1)<=0x5A || newtxt.charCodeAt(1)>=0x61)) {
						if(outch.charAt(0) !== outch.charAt(0).toUpperCase() && newtxt.charAt(1) !== newtxt.charAt(1).toLowerCase()) {
							txtout = txtout.substring(0,txtout.length-1) + outch.charAt(0).toUpperCase() + newtxt.charAt(1).toLowerCase();
							}
						else {
							txtout = txtout.substring(0,txtout.length-1) + outch.charAt(0) + newtxt.charAt(1);
							}
						if(outch.length>1) {
							outch = outch.substring(1);
							}
						else {
							outch = "";
							}
						}
					break;
				case "G":
				case "g":
				case "K":
				case "k":
				case "X":
				case "x":
					newtxt=txtout.substring(txtout.length-1);
					switch(newtxt.charAt(0)) {
						case "G":
							txtout = txtout.substring(0,txtout.length-1) + "N";
							break;
						case "g":
							txtout = txtout.substring(0,txtout.length-1) + "n";
					}
					break;
				case "R":
				case "r":
					newtxt=txtout.substring(txtout.length-1);
					switch(newtxt.charAt(0)) {
						case "R":
						case "r":
							if(outch.length===1) {
								outch = outch.charAt(0) + String.fromCharCode(outch.charCodeAt(0)-10);
								}
							else {
								outch = outch.charAt(0) + String.fromCharCode(outch.charCodeAt(0)-10) + outch.substring(0,outch.length);
								}
					}
			}
			if(outch.toLowerCase() !== outch) {
				newtxt=txtout.substring(txtout.length-1);
				if(newtxt!==newtxt.toUpperCase()) {
					txtout = txtout.substring(0,txtout.length-1) + newtxt.toUpperCase();
					}
			}
		}
		txtout = txtout + outch;
	}
	return txtout;
}