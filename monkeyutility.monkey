''
'' helper classes and functions for monkey conversion
''

Import monkey
Import tutility
Import minib3d
Import minib3d.monkeybuffer
Import os


Alias LoadString = app.LoadString




Function AllocateFloatArray:Float[][]( i:Int, j:Int)
    Local arr:Float[][] = New Float[i][]
    For Local ind = 0 Until i
        arr[ind] = New Float[j]
    Next
    Return arr		
End

Function AllocateIntArray:Int[][]( i:Int, j:Int)
    Local arr:Int[][] = New Int[i][]
    For Local ind = 0 Until i
        arr[ind] = New Int[j]
    Next
    Return arr		
End




''
'' base64 functions
''
'' -- using little-endian, ieee 32 bit single-precision float
''

Class Base64 Extends BufferReader

	Global MIME$="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	Global Dime:Int[]
	
	
	Field temp_str:String
	
	Global realsize:Int=0
	

	
	Method Free()
	
		data = Null
		pos = 0
		
	End
	
	Function Load:Base64(file$)
		
		Local bsf:Base64 = New Base64
		
		bsf.data = Decode(LoadString(file))
		bsf.pos = 0
		bsf.size = realsize-1
		
		Return bsf
		
	End
	
	Function LoadStr:Base64(s$)
		
		Local bsf:Base64 = New Base64
		
		bsf.data = Decode(s)
		bsf.pos = 0
		bsf.size = realsize-1
		
		Return bsf
		
	End
	
	''
	'' Encode() from skid
	'' -- doesn't work for DataBuffers *to do*
	''
	Function Encode$(bytes:Int[])
		Local n=bytes.Length	
		Local buffer$
		Local blank:String = ""
	
		For Local i=0 Until n Step 3	
			Local b0,b1,b2,b24
			Local pad$
			b0=bytes[i]
			If i+1<n
				b1=bytes[i+1]
				If i+2<n
					b2=bytes[i+2]
				Else
					pad="="
				Endif
			Else
				pad="=="
			Endif		
			b24=(b0 Shl 16) | (b1 Shl 8) | (b2)
			buffer.Join(String.FromChar( MIME[(b24 Shr 18)&63] ) ,blank )
			buffer.Join(String.FromChar( MIME[(b24 Shr 12)&63] ) ,blank  )
			buffer.Join(String.FromChar( MIME[(b24 Shr 6)&63] ) ,blank  )
			buffer.Join(String.FromChar( MIME[(b24)&63] ) ,blank  )
			If pad Then buffer.Join(pad, blank )	
		Next	
	
		Return buffer
	End
	
	''
	'' Decode() from skid
	''
	Function Decode:DataBuffer(mime$)
	
		If Not Dime
		
			Dime=New Int[256]
			For Local i=0 To 63
				Dime[MIME[i]]=i
			Next
			
		Endif
		
		'Local bytes:Int[]
		Local m_length=mime.Length
		Local pad, length
		Local i,p,i4
		
		realsize =0 
		
		
		If m_length=0 Then Return CreateDataBuffer(0)
		
		If mime[m_length-1]="="[0] 
			pad=1
			If mime[m_length-2]="="[0]
				pad=2
				If mime[m_length-3]="="[0]
					pad=3
				Endif
			Endif
		Endif	
		
		length=Int((m_length-pad)/4+0.5)*3 ''round up
		'bytes=New Int[length]
		Local buf:DataBuffer = CreateDataBuffer(length+3) ''making this +3 will catch early eof errors
		Local bb:Int[4]
		
		While p<m_length-1
		
			bb = [0,0,0,0]
			
			''handle text breakups
			For Local j:Int=0 To 3
				
				If (p+j) >= m_length Then Exit
				
				bb[j] = mime[p+j]
				While (bb[j]<33)
					p+=1 
					If p>= m_length Then Exit

					bb[j] = mime[p+j]
				Wend
				If bb[j] > 255 Then bb[j] =0 ''handle odd memory errors
				bb[j]=Dime[ bb[j] ]
	
			Next

			Local b24:Int =(bb[0] Shl 18)|(bb[1] Shl 12)|(bb[2] Shl 6)|bb[3]		
			
			''beware of early eof
			buf.PokeByte( i+0, (b24 Shr 16)&255)
			buf.PokeByte( i+1, (b24 Shr 8)&255)
			buf.PokeByte( i+2, (b24 )&255)
			p+=4
			i+=3
			
			realsize +=3 'bytes
		Wend	
		'If pad
			'bytes=bytes.Resize(length-pad)
		'Endif	
		
		Local buf2:DataBuffer = CreateDataBuffer(realsize-1)
		CopyDataBuffer(buf, buf2)
		buf = Null
		
		Return buf2
	End
End




Function CreateMiniB3DMonkey:TMesh()

	Local MINIB3DMONKEY1$= "o minib3d_logo.obj~nmtllib minib3d_logo.mtl~ng default~nv -0.95 -1.0505 0.924505~nv -0.95 -1.0505 -0.975495~nv 0.95 -1.0505 -0.975495~nv 0.95 -1.0505 0.924505~nv -0.95 0.8495 0.924505~nv -0.95 0.8495 -0.975495~nv -0.95 -1.0505 -0.975495~nv -0.95 -1.0505 0.924505~nv 0.95 0.8495 -0.975495~nv -0.95 0.8495 -0.975495~nv -0.95 0.8495 0.924505~nv 0.95 0.8495 0.924505~nv 0.95 -1.0505 -0.975495~nv 0.95 0.8495 -0.975495~nv 0.95 0.8495 0.924505~nv 0.95 -1.0505 0.924505~nv -0.95 -1.0505 -0.975495~nv -0.95 0.8495 -0.975495~nv 0.95 0.8495 -0.975495~nv 0.95 -1.0505 -0.975495~nv -0.330252 0.2404 0.975495~nv -0.533484 0.2404 0.975495~nv -0.533484 0.0652 0.975495~nv -0.330252 0.0652 0.975495~nv -0.533484 0.0652 0.975495~nv -0.533484 0.0652 0.503331~nv -0.330252 0.0652 0.503331~nv -0.330252 0.0652 0.975495~n"+
	"v -0.533484 0.2404 0.975495~nv -0.533484 0.2404 0.503331~nv -0.533484 0.0652 0.503331~nv -0.533484 0.0652 0.975495~nv -0.330252 0.2404 0.503331~nv -0.533484 0.2404 0.503331~nv -0.533484 0.2404 0.975495~nv -0.330252 0.2404 0.975495~nv -0.330252 0.0652 0.503331~nv -0.330252 0.2404 0.503331~nv -0.330252 0.2404 0.975495~nv -0.330252 0.0652 0.975495~nv -0.533484 0.0652 0.503331~nv -0.533484 0.2404 0.503331~nv -0.330252 0.2404 0.503331~nv -0.330252 0.0652 0.503331~nv 0.533484 0.2404 0.975495~nv 0.330252 0.2404 0.975495~nv 0.330252 0.0652 0.975495~nv 0.533484 0.0652 0.975495~nv 0.330252 0.0652 0.975495~nv 0.330252 0.0652 0.503331~nv 0.533484 0.0652 0.503331~nv 0.533484 0.0652 0.975495~nv 0.330252 0.2404 0.975495~nv 0.330252 0.2404 0.503331~nv 0.330252 0.0652 0.503331~nv 0.330252 0.0652 0.975495~nv 0.533484 0.2404 0.503331~n"+
	"v 0.330252 0.2404 0.503331~nv 0.330252 0.2404 0.975495~nv 0.533484 0.2404 0.975495~nv 0.533484 0.0652 0.503331~nv 0.533484 0.2404 0.503331~nv 0.533484 0.2404 0.975495~nv 0.533484 0.0652 0.975495~nv 0.330252 0.0652 0.503331~nv 0.330252 0.2404 0.503331~nv 0.533484 0.2404 0.503331~nv 0.533484 0.0652 0.503331~nv -1.25 0.2495 0.224505~nv -1.25 0.2495 -0.175495~nv -1.25 -0.3505 -0.175495~nv -1.25 -0.3505 0.224505~nv -1.25 -0.3505 -0.175495~nv -0.811969 -0.3505 -0.175495~nv -0.811969 -0.3505 0.224505~nv -1.25 -0.3505 0.224505~nv -1.25 0.2495 -0.175495~nv -0.811969 0.2495 -0.175495~nv -0.811969 -0.3505 -0.175495~nv -1.25 -0.3505 -0.175495~nv -0.811969 0.2495 0.224505~nv -0.811969 0.2495 -0.175495~nv -1.25 0.2495 -0.175495~nv -1.25 0.2495 0.224505~nv -0.811969 -0.3505 0.224505~nv -0.811969 0.2495 0.224505~nv -1.25 0.2495 0.224505~n"+
	"v -1.25 -0.3505 0.224505~nv -0.811969 -0.3505 -0.175495~nv -0.811969 0.2495 -0.175495~nv -0.811969 0.2495 0.224505~nv -0.811969 -0.3505 0.224505~nv 1.25 -0.3505 -0.175495~nv 1.25 0.2495 -0.175495~nv 1.25 0.2495 0.224505~nv 1.25 -0.3505 0.224505~nv 0.811969 -0.3505 0.224505~nv 0.811969 -0.3505 -0.175495~nv 1.25 -0.3505 -0.175495~nv 1.25 -0.3505 0.224505~nv 0.811969 -0.3505 -0.175495~nv 0.811969 0.2495 -0.175495~nv 1.25 0.2495 -0.175495~nv 1.25 -0.3505 -0.175495~nv 1.25 0.2495 -0.175495~nv 0.811969 0.2495 -0.175495~nv 0.811969 0.2495 0.224505~nv 1.25 0.2495 0.224505~nv 1.25 0.2495 0.224505~nv 0.811969 0.2495 0.224505~nv 0.811969 -0.3505 0.224505~nv 1.25 -0.3505 0.224505~nv 0.811969 0.2495 0.224505~nv 0.811969 0.2495 -0.175495~nv 0.811969 -0.3505 -0.175495~nv 0.811969 -0.3505 0.224505~nv -0.1 0.798 0.244005~nv -0.1 0.798 0.244005~n"+
	"v -0.25 1.0505 0.244005~nv -0.4 0.798 0.244005~nv -0.25 1.0505 0.244005~nv -0.25 1.0505 -0.168274~nv -0.4 0.798 -0.168274~nv -0.4 0.798 0.244005~nv -0.1 0.798 0.244005~nv -0.1 0.798 -0.168274~nv -0.25 1.0505 -0.168274~nv -0.25 1.0505 0.244005~nv -0.1 0.798 -0.168274~nv -0.1 0.798 -0.168274~nv -0.1 0.798 0.244005~nv -0.1 0.798 0.244005~nv -0.4 0.798 -0.168274~nv -0.1 0.798 -0.168274~nv -0.1 0.798 0.244005~nv -0.4 0.798 0.244005~nv -0.25 1.0505 -0.168274~nv -0.1 0.798 -0.168274~nv -0.1 0.798 -0.168274~nv -0.4 0.798 -0.168274~nv -0.52 0.798 0.244005~nv -0.52 0.798 0.244005~nv -0.67 1.0505 0.244005~nv -0.82 0.798 0.244005~nv -0.67 1.0505 0.244005~nv -0.67 1.0505 -0.168274~nv -0.82 0.798 -0.168274~nv -0.82 0.798 0.244005~nv -0.52 0.798 0.244005~nv -0.52 0.798 -0.168274~nv -0.67 1.0505 -0.168274~nv -0.67 1.0505 0.244005~nv -0.52 0.798 -0.168274~n"+
	"v -0.52 0.798 -0.168274~nv -0.52 0.798 0.244005~nv -0.52 0.798 0.244005~nv -0.82 0.798 -0.168274~nv -0.52 0.798 -0.168274~nv -0.52 0.798 0.244005~nv -0.82 0.798 0.244005~nv -0.67 1.0505 -0.168274~nv -0.52 0.798 -0.168274~nv -0.52 0.798 -0.168274~nv -0.82 0.798 -0.168274~nv -0.31 0.798 0.244005~nv -0.31 0.798 0.244005~nv -0.46 1.0505 0.244005~nv -0.61 0.798 0.244005~nv -0.46 1.0505 0.244005~nv -0.46 1.0505 -0.168274~nv -0.61 0.798 -0.168274~nv -0.61 0.798 0.244005~nv -0.31 0.798 0.244005~nv -0.31 0.798 -0.168274~nv -0.46 1.0505 -0.168274~nv -0.46 1.0505 0.244005~nv -0.31 0.798 -0.168274~nv -0.31 0.798 -0.168274~nv -0.31 0.798 0.244005~nv -0.31 0.798 0.244005~nv -0.61 0.798 -0.168274~nv -0.31 0.798 -0.168274~nv -0.31 0.798 0.244005~nv -0.61 0.798 0.244005~nv -0.46 1.0505 -0.168274~nv -0.31 0.798 -0.168274~nv -0.31 0.798 -0.168274~n"+
	"v -0.61 0.798 -0.168274~nv 0.95 0.8495 0.924505~nv 0.8 0.6995 0.874505~nv 0.8 -0.9005 0.874505~nv 0.95 -1.0505 0.924505~nv 0.8 -0.9005 0.874505~nv -0.8 -0.9005 0.874505~nv -0.95 -1.0505 0.924505~nv 0.95 -1.0505 0.924505~nv -0.8 -0.9005 0.874505~nv -0.8 0.6995 0.874505~nv -0.95 0.8495 0.924505~nv -0.95 -1.0505 0.924505~nv 0.95 0.8495 0.924505~nv -0.95 0.8495 0.924505~nv -0.8 0.6995 0.874505~nv 0.8 0.6995 0.874505~nv 0.8 0.6995 0.874505~nv -0.8 0.6995 0.874505~nv -0.8 -0.9005 0.874505~nv 0.8 -0.9005 0.874505~nvn -0.611216 -0.347834 0.710933~nvn -0.611216 -0.347834 0.710933~nvn -0.611216 -0.347834 -0.710933~nvn -0.611216 -0.347834 -0.710933~nvn -0.57735 -0.57735 0.57735~nvn -0.57735 -0.57735 -0.57735~nvn -0.57735 -0.57735 -0.57735~nvn -0.57735 0.57735 -0.57735~nvn -0.57735 0.57735 0.57735~nvn -0.57735 0.57735 -0.57735~nvn -0.321084 0.321084 0.89096~n"+
	"vn -0.321084 -0.321084 0.89096~nvn -0.162221 -0.162221 0.973329~nvn -0.162221 0.162221 0.973329~nvn -0.12395 0.451338 0.883703~nvn -0.12395 0.451338 -0.883703~nvn -0.12395 0.451338 0.883703~nvn -0.12395 0.451338 -0.883703~nvn 0 0 1~nvn 0 0.714577 0.699557~nvn 0 0.714577 -0.699557~nvn 4.16968e-008 0.714577 0.699557~nvn 4.16968e-008 0.714577 -0.699557~nvn 4.16968e-008 0.714577 0.699557~nvn 4.16968e-008 0.714577 -0.699557~nvn 0.162221 -0.162221 0.973329~nvn 0.162221 0.162221 0.973329~nvn 0.321084 -0.321084 0.89096~nvn 0.321084 0.321084 0.89096~nvn 0.57735 -0.57735 0.57735~nvn 0.57735 -0.57735 -0.57735~nvn 0.57735 -0.57735 -0.57735~nvn 0.57735 0.57735 -0.57735~nvn 0.57735 0.57735 0.57735~nvn 0.57735 0.57735 -0.57735~ng minib3d_logo_1~nusemtl brown~ns off~nf 1//12 2//7 3//32 4//28~nf 5//11 6//8 7//7 8//12~nf 9//33 10//8 11//11 12//29~nf 13//32 14//33 15//29 16//28~n"
	
	Local MINIB3DMONKEY2$="f 17//7 18//8 19//33 20//32~nusemtl black~ns off~nf 21//34 22//9 23//5 24//30~nf 25//5 26//6 27//31 28//30~nf 29//9 30//10 31//6 32//5~nf 33//35 34//10 35//9 36//34~nf 37//31 38//35 39//34 40//30~nf 41//6 42//10 43//35 44//31~nf 45//34 46//9 47//5 48//30~nf 49//5 50//6 51//31 52//30~nf 53//9 54//10 55//6 56//5~nf 57//35 58//10 59//9 60//34~nf 61//31 62//35 63//34 64//30~nf 65//6 66//10 67//35 68//31~nusemtl yellow~ns off~nf 69//9 70//10 71//6 72//5~nf 73//6 74//31 75//30 76//5~nf 77//10 78//35 79//31 80//6~nf 81//34 82//35 83//10 84//9~nf 85//30 86//34 87//9 88//5~nf 89//31 90//35 91//34 92//30~nf 93//31 94//35 95//34 96//30~nf 97//5 98//6 99//31 100//30~nf 101//6 102//10 103//35 104//31~nf 105//35 106//10 107//9 108//34~nf 109//34 110//9 111//5 112//30~nf 113//9 114//10 115//6 116//5~nusemtl brown~ns off~nf 117//5 118//15 119//20 120//2~nf 121//20 122//21 123//3 124//2~n"+
	"f 125//15 126//16 127//21 128//20~nf 129//6 130//16 131//15 132//5~nf 133//3 134//6 135//5 136//2~nf 137//21 138//16 139//6 140//3~nf 141//5 142//17 143//24 144//2~nf 145//24 146//25 147//3 148//2~nf 149//17 150//18 151//25 152//24~nf 153//6 154//18 155//17 156//5~nf 157//3 158//6 159//5 160//2~nf 161//25 162//18 163//6 164//3~nf 165//5 166//15 167//22 168//1~nf 169//22 170//23 171//4 172//1~nf 173//15 174//16 175//23 176//22~nf 177//6 178//16 179//15 180//5~nf 181//4 182//6 183//5 184//1~nf 185//23 186//16 187//6 188//4~nf 189//29 190//13 191//14 192//28~nf 193//14 194//27 195//12 196//28~nf 197//27 198//26 199//11 200//12~nf 201//29 202//11 203//26 204//13~nusemtl yellow~ns off~nf 205//19 206//19 207//19 208//19~ng Default~nv -0.475196 -0.40127 0.194883~nv -0.475196 -0.21219 0.194883~nv -0.304439 -0.21219 0.194883~nv -0.304439 -0.40127 0.194883~nv -0.30457 -0.40054 0.194883~n"+
	"v -0.30457 -0.292135 0.194883~nv 0.310419 -0.292865 0.194883~nv 0.310419 -0.40127 0.194883~nv 0.310287 -0.40127 0.194883~nv 0.310287 -0.21219 0.194883~nv 0.481045 -0.21219 0.194883~nv 0.481045 -0.40127 0.194883~nv -0.304439 -0.21219 0.194883~nv -0.304439 -0.21219 0.953718~nv -0.304439 -0.40127 0.953718~nv -0.304439 -0.40127 0.194883~nv -0.475196 -0.21219 0.194883~nv -0.475196 -0.21219 0.953718~nv -0.304439 -0.21219 0.953718~nv -0.304439 -0.21219 0.194883~nv -0.475196 -0.40127 0.953718~nv -0.475196 -0.21219 0.953718~nv -0.475196 -0.21219 0.194883~nv -0.475196 -0.40127 0.194883~nv -0.304439 -0.40127 0.953718~nv -0.475196 -0.40127 0.953718~nv -0.475196 -0.40127 0.194883~nv -0.304439 -0.40127 0.194883~nv 0.310419 -0.292865 0.194883~nv 0.310419 -0.292865 0.953718~nv 0.310419 -0.40127 0.953718~nv 0.310419 -0.40127 0.194883~nv -0.30457 -0.292135 0.953718~nv 0.310419 -0.292865 0.953718~n"+
	"v 0.310419 -0.292865 0.194883~nv -0.30457 -0.292135 0.194883~nv -0.30457 -0.40054 0.953718~nv -0.30457 -0.292135 0.953718~nv -0.30457 -0.292135 0.194883~nv -0.30457 -0.40054 0.194883~nv 0.310419 -0.40127 0.194883~nv 0.310419 -0.40127 0.953718~nv -0.30457 -0.40054 0.953718~nv -0.30457 -0.40054 0.194883~nv 0.481045 -0.21219 0.194883~nv 0.481045 -0.21219 0.953718~nv 0.481045 -0.40127 0.953718~nv 0.481045 -0.40127 0.194883~nv 0.310287 -0.21219 0.953718~nv 0.481045 -0.21219 0.953718~nv 0.481045 -0.21219 0.194883~nv 0.310287 -0.21219 0.194883~nv 0.310287 -0.40127 0.953718~nv 0.310287 -0.21219 0.953718~nv 0.310287 -0.21219 0.194883~nv 0.310287 -0.40127 0.194883~nv 0.481045 -0.40127 0.194883~nv 0.481045 -0.40127 0.953718~nv 0.310287 -0.40127 0.953718~nv 0.310287 -0.40127 0.194883~nv -0.304439 -0.40127 0.953718~nv -0.304439 -0.21219 0.953718~nv -0.475196 -0.21219 0.953718~n"+
	"v -0.475196 -0.40127 0.953718~nv -0.304439 -0.40127 0.953718~nv 0.310287 -0.40127 0.953718~nv 0.310419 -0.292865 0.953718~nv -0.30457 -0.292135 0.953718~nv 0.481045 -0.40127 0.953718~nv 0.481045 -0.21219 0.953718~nv 0.310287 -0.21219 0.953718~nv 0.310287 -0.40127 0.953718~nvn -0.707526 -0.706687 -0~nvn -0.577807 -0.577122 -0.577122~nvn -0.57735 -0.57735 0.57735~nvn -0.57735 -0.57735 -0.57735~nvn -0.57735 0.57735 0.57735~nvn -0.57735 0.57735 -0.57735~nvn -0.576893 0.577578 0.577579~nvn -0.576893 0.577578 -0.577579~nvn -0.408248 -0.408248 0.816497~nvn 0.408248 -0.408248 0.816497~nvn 0.576893 -0.577578 -0.577579~nvn 0.57735 -0.57735 0.57735~nvn 0.57735 -0.57735 -0.57735~nvn 0.57735 0.57735 0.57735~nvn 0.57735 0.57735 -0.57735~nvn 0.577807 0.577122 0.577122~nvn 0.577807 0.577122 -0.577122~nvn 0.706687 -0.707526 -0~ng minib3d_logo_2~nusemtl black~ns off~nf 209//39 210//41 211//50 212//48~n"+
	"f 213//37 214//43 215//52 216//46~nf 217//39 218//41 219//50 220//48~nf 221//50 222//49 223//45 224//48~nf 225//41 226//40 227//49 228//50~nf 229//38 230//40 231//41 232//39~nf 233//45 234//38 235//39 236//48~nf 237//52 238//51 239//53 240//46~nf 241//42 242//51 243//52 244//43~nf 245//36 246//42 247//43 248//37~nf 249//46 250//53 251//36 252//37~nf 253//50 254//49 255//47 256//48~nf 257//40 258//49 259//50 260//41~nf 261//44 262//40 263//41 264//39~nf 265//48 266//47 267//44 268//39~nf 269//45 270//49 271//40 272//38~nf 273//45 274//44 275//51 276//42~nf 277//47 278//49 279//40 280//44~n"
	
	Local mtl$ = "newmtl black~nKa 0 0 0~nKd 0.156863 0.156863 0.156863~nKs 0 0 0~nNi 1~nNs 400~nTf 1 1 1~nd 1~n~nnewmtl brown~nKa 0 0 0~nKd 0.537255 0.396078 0.286275~nKs 0 0 0~nNi 1~nNs 400~nTf 1 1 1~nd 1~n~nnewmtl yellow~nKa 0 0 0~nKd 0.996078 0.929412 0.662745~nKs 0 0 0~nNi 1~nNs 400~nTf 1 1 1~nd 1~n~n"
	Local m:TMesh = TModelObj.LoadMeshString(MINIB3DMONKEY1+MINIB3DMONKEY2,mtl)
	m.UpdateNormals()
	Return m

End
