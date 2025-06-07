BEGIN {
   in_comment = 0;
   split("",commands);
   n_commands = 0;
   split("",open_brces);
   n_open_brces = 0;
}
{
   L = length($0);
   for (i=1; i<=L; i++) {
      c = substr($0,i,1);
      if (in_comment && c == ")") {
         in_comment = 0;
      } else if (in_comment) {
         # skip
      } else if (c == "(") {
         in_comment = 1;
      } else if (c ~ /^[!*>^_{|}<,.+-]$/) {
         commands[++n_commands] = c;
      } else if (c == "[" || c == "]") {
	 n_commands++;
	 my_cmd = c;
	 if (c == "[") {
	    open_brces[++n_open_brces] = n_commands;
	 } else if (c == "]" && n_open_brces > 0) {
	    that_addr = open_brces[n_open_brces--];
	    commands[that_addr] = commands[that_addr] OFS (n_commands + 1);
	    my_cmd = my_cmd OFS (that_addr+1);
	 } else {
	    my_cmd = my_cmd OFS "*";
	 }
	 commands[n_commands] = my_cmd;
      }
   }
}
END {
   if (in_comment) {
      print "Tokenizer error: Unclosed comment" | "cat 1>&2";
      exit 1;
   }

   for (;n_open_brces>0;) {
      that_addr = open_brces[n_open_brces--];
      commands[that_addr] = commands[that_addr] OFS "*";
   }

   for (i=1; i<=n_commands; i++) {
      print i,commands[i];
   }
}
