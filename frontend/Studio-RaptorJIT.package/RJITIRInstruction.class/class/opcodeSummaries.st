as yet unclassified
opcodeSummaries
	^ {
  #lt -> 'LT (left, right): left < right (signed)'.
  #ge -> 'GE (left, right): left >= right (signed)'.
  #le -> 'LE (left, right): left <= right (signed)'.
  #gt -> 'GT (left, right): left > right (signed)'.
  #ult -> 'ULT (left, right): left < right (unsigned/unordered)'.
  #uge -> 'UGE (left, right): left >= right (unsigned/unordered)'.
  #ule -> 'ULE (left, right): left <= right (unsigned/unordered)'.
  #ugt -> 'UGT (left, right): left > right (unsigned/unordered)'.
  #eq -> 'EQ (left, right): left = right'.
  #ne -> 'NE (left, right): left ~= right'.
  #abc -> 'ABC (bound, index): Array Bounds Check: bound > index (unsigned)'.
  #retf -> 'RETF (proto, pc): Return to lower frame: check target PC, shift base'.
  #bnot -> 'BNOT (ref): Bitwise NOT of ref'.
  #bswap -> 'BSWAP (ref): Byte-swapped ref'.
  #band -> 'BAND (left, right): Bitwise AND of left and right'.
  #bor -> 'BOR (left, right): Bitwise OR of left and right'.
  #bxor -> 'BXOR (left, right): Bitwise XOR of left and right'.
  #bshl -> 'BSHL (ref, shift): Bitwise left shift of ref'.
  #bshr -> 'BSHR (ref, shift): Bitwise logical right shift of ref'.
  #bsar -> 'BSAR (ref, shift): Bitwise arithmetic right shift of ref'.
  #brol -> 'BROL (ref, shift): Bitwise left rotate of ref'.
  #bror -> 'BROR (ref, shift): Bitwise right rotate of ref'.
  #add -> 'ADD (left, right): left + right'.
  #sub -> 'SUB (left, right): left - right'.
  #mul -> 'MUL (left, right): left * right'.
  #div -> 'DIV (left, right): left / right'.
  #mod -> 'MOD (left, right): left % right'.
  #pow -> 'POW (left, right): left ^ right'.
  #neg -> 'NEG (ref, kneg): -ref'.
  #abs -> 'ABS (ref, kabs): abs(ref)'.
  #atan2 -> 'ATAN2 (left, right): atan2(left, right)'.
  #ldexp -> 'LDEXP (left, right): ldexp(left, right)'.
  #min -> 'MIN (left, right): min(left, right)'.
  #max -> 'MAX (left, right): max(left, right)'.
  #fpmath -> 'FPMATH (ref, #fpm): fpmath(ref)'.
  #addov -> 'ADDOV (left, right): left + right, overflow-checked'.
  #subov -> 'SUBOV (left, right): left - right, overflow-checked'.
  #mulov -> 'MULOV (left, right): left * right, overflow-checked'.
  #fpm_floor -> 'FPM_FLOOR       floor(ref)'.
  #fpm_ceil -> 'FPM_CEIL        ceil(ref)'.
  #fpm_trunc -> 'FPM_TRUNC       trunc(ref)'.
  #fpm_sqrt -> 'FPM_SQRT        sqrt(ref)'.
  #fpm_exp -> 'FPM_EXP         exp(ref)'.
  #fpm_exp2 -> 'FPM_EXP2        exp2(ref)'.
  #fpm_log -> 'FPM_LOG         log(ref)'.
  #fpm_log2 -> 'FPM_LOG2        log2(ref)'.
  #fpm_log10 -> 'FPM_LOG10       log10(ref)'.
  #fpm_sin -> 'FPM_SIN         sin(ref)'.
  #fpm_cos -> 'FPM_COS         cos(ref)'.
  #fpm_tan -> 'FPM_TAN         tan(ref)'.
  #aref -> 'AREF (array, index): Array reference'.
  #hrefk -> 'HREFK (hash, kslot): Constant hash reference'.
  #href -> 'HREF (tab, key): Hash reference'.
  #newref -> 'NEWREF (tab, key): Create new reference'.
  #urefo -> 'UREFO (func, #uv): Open upvalue reference'.
  #urefc -> 'UREFC (func, #uv): Closed upvalue reference'.
  #fref -> 'FREF (obj, #field): Object field reference'.
  #strref -> 'STRREF (str, index): String reference'.
  #aload -> 'ALOAD (aref): Array load'.
  #hload -> 'HLOAD (href): Hash load'.
  #uload -> 'ULOAD (uref): Upvalue load'.
  #fload -> 'FLOAD (obj, #field): Object field load'.
  #xload -> 'XLOAD (xref, #flags): Extended load'.
  #sload -> 'SLOAD (#slot, #flags): Stack slot load'.
  #vload -> 'VLOAD (aref): Vararg slot load'.
  #astore -> 'ASTORE (aref, val): Array store'.
  #hstore -> 'HSTORE (href, val): Hash store'.
  #ustore -> 'USTORE (uref, val): Upvalue store'.
  #fstore -> 'FSTORE (fref, val): Object field store'.
  #xstore -> 'XSTORE (xref, val): Extended store'.
  #snew -> 'SNEW (data, length): Allocate interned string'.
  #xsnew -> 'XSNEW (data, length): Allocate interned string from cdata'.
  #tnew -> 'TNEW (#asize, #hbits): Allocate Lua table with minimum array and hash sizes'.
  #tdup -> 'TDUP (template): Allocate Lua table, copying a template table'.
  #cnew -> 'CNEW (ctypeid, size): Allocate mutable cdata'.
  #cnewi -> 'CNEWI (ctypeid, val): Allocate immutable cdata'.
  #tbar -> 'TBAR (tab): Table write barrier'.
  #obar -> 'OBAR (obj, val): Object write barrier'.
  #xbar -> 'XBAR: XLOAD/XSTORE optimization barrier'.
  #conv -> 'CONV (src, #flags): Generic type conversion'.
  #tobit -> 'TOBIT (num, bias): Convert double to integer with Lua BitOp semantics'.
  #tostr -> 'TOSTR (number): Convert double or integer to string'.
  #strto -> 'STRTO (str): Convert string to double'.
  #calln -> 'CALLN (args, #ircall): Call internal function (normal)'.
  #calll -> 'CALLL (args, #ircall): Call internal function (load)'.
  #calls -> 'CALLS (args, #ircall): Call internal function (store)'.
  #callxs -> 'CALLXS (args, func): Call external function (store/barrier)'.
  #carg -> 'CARG (args, arg): Call argument extension'.
  #nop -> 'NOP: No operation'.
  #base -> 'BASE (#parent, #exit): BASE reference, link to parent side exit'.
  #pval -> 'PVAL (#pref): Parent value reference'.
  #gcstep -> 'GCSTEP: Explicit GC step'.
  #hiop -> 'HIOP (left, right): Hold hi-word operands of split instructions'.
  #loop -> 'LOOP: Separator before loop-part of a trace'.
  #use -> 'USE (ref): Explicit use of a reference'.
  #phi -> 'PHI (left, right): PHI node for loops'.
  #rename -> 'RENAME (ref, #snap): Renamed reference below snapshot'.
} asDictionary.