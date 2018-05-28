Runtime-less disassembly of Borland's `MAKER.EXE`, version 4.0, bundled with
Turbo Assembler 5.0, created to figure out why the hell autodependencies aren't
working as I would expect.

## So, why didn't they work?
Or rather, how *are* they supposed to work. Here's a minimal working example,
assuming that there is a `autodept.c` file in the same directory:

```Makefile
.autodepend

autodept.com: autodept.obj
	$(CC) -mt -lt $**
```

And this *does* allow you to change `autodept.c` or any file `#include`d in it,
and re-running `make` will rebuild both `autodept.com` and `autodept.obj`.

Note how you absolutely have to list the `.obj` file in the dependency list.
Borland MAKE is *not* smart enough to realize that commands might produce .obj
files with autodependency information for `.c`/`.cpp`/`.asm` dependencies as a
byproduct.

### There's still a problem, though.

You'd expect a target to be unconditionally invalidated and rebuilt after a
dependent `.obj` was rebuilt as a result of an autodependency check. However,
after the execution of the `obj` file's build commands, Borland MAKE then still
retrieves the *system time*, and only rebuilds the target if that system time
is *greater than* the modification time of the target file. (Yes, not even
"greater than *or equal to*".)
This introduces two potential problems:

1. Since it's (at least) 2018 and you'll be running this in a VM, you're at the
   mercy of your VM's implementation of [INT 21h, AX=2Ah (GET SYSTEM DATE)]
   and [INT 21h, AX=2Ch (GET SYSTEM TIME)] for something that shouldn't involve
   time to begin with. DOSBox 0.7.4 in particular is known for returning
   inaccurate values that often are way behind the current host system clock,
   probably due to compatibility issues with other programs.
2. Borland MAKE internally uses FAT timestamps with a precision of 2 seconds,
   which introduces further inaccuracy.

In the end, you might have to run `MAKE` twice to make sure that all targets
are up-to-date. This could easily be solved by just returning the highest
possible timestamp, `FFFF:FFFF`, from the `systime_to_fattime` function:

```diff
diff --git a/MAKER40.ASM b/MAKER40.ASM
index 3bc96ee..fc0f8fd 100644
--- a/MAKER40.ASM
+++ b/MAKER40.ASM
@@ -11465,56 +11465,13 @@ mtime_get	endp

 ; fattime_t __pascal systime_as_fattime()
 systime_as_fattime	proc pascal near
-	local @@timep:time, @@datep:date, @@ret:fattime_t

-		push	ss
-		lea	ax, @@datep
-		push	ax
-		call	_getdate
-		add	sp, 4
-		push	ss
-		lea	ax, @@timep
-		push	ax
-		call	_gettime
-		add	sp, 4
-		mov	al, @@timep.ti_sec
-		mov	ah, 0
-		sar	ax, 1
-		and	ax, 1Fh
-		and	byte ptr @@ret.ftime, 0E0h
-		or	byte ptr @@ret.ftime, al
-		mov	al, @@timep.ti_min
-		mov	ah, 0
-		and	ax, 3Fh
-		and	@@ret.ftime, 0F81Fh
-		shl	ax, 5
-		or	@@ret.ftime, ax
-		mov	al, @@timep.ti_hour
-		mov	ah, 0
-		and	ax, 1Fh
-		and	@@ret.ftime, 7FFh
-		shl	ax, 0Bh
-		or	@@ret.ftime, ax
-		mov	al, @@datep.da_day
-		cbw
-		and	ax, 1Fh
-		and	byte ptr @@ret.fdate, 0E0h
-		or	byte ptr @@ret.fdate, al
-		mov	al, @@datep.da_mon
-		cbw
-		and	ax, 0Fh
-		and	@@ret.fdate, 0FE1Fh
-		shl	ax, 5
-		or	@@ret.fdate, ax
-		mov	ax, @@datep.da_year
-		add	ax, 0F844h
-		and	ax, 7Fh
-		and	@@ret.fdate, 1FFh
-		shl	ax, 9
-		or	@@ret.fdate, ax
-		mov	dx, @@ret.fdate
-		mov	ax, @@ret.ftime
+		mov	dx, 0FFFFh
+		mov	ax, 0FFFFh
 		ret
+		db "^ (Always rebuilds targets if we rebuilt a dependency. "
+		db "Original binary only did if systime > target mtime. "
+		db "Bad idea in 2018 --Nmlgc)", 0, 0
 systime_as_fattime	endp
```

The time part translates to a time of 31:63:62, which will always be greater
than any real timestamp. (In fact, the function for checking autodependencies
also returns that value if the `.obj` needs to be rebuilt.)

## Building
You will need the following to compile this back into the original binary:

* Borland C++ 5.01.

  Yes, and by that I mean probably this specific version. 4.52 is too old, 5.02
  is too new. 4.53 and 5.0 are untested.

* Borland Turbo Assembler (TASM), version 5.0 or later, in a 16-bit Protected
  Mode DOS version (`TASMX.EXE`). `TASM32.EXE` would work too, but `TASMX.EXE`
  can keep the build process entirely 16-bit.

* [DOSBox](http://dosbox.com) if you're running a 64-bit version of Windows, or
  a non-Windows operating system.

  To build, simply run `build16b.bat` and follow the instructions.

----

[INT 21h, AX=2Ah (GET SYSTEM DATE)]: http://www.ctyme.com/intr/rb-2686.htm
[INT 21h, AX=2Ch (GET SYSTEM TIME)]: http://www.ctyme.com/intr/rb-2703.htm
