define curinfo
	printf "%d:%s\n", my_perl->Tcurcop->cop_line, my_perl->Tcurcop->cop_file
end

define longmess
	set $sv = Perl_eval_pv(my_perl, "Carp::longmess()", 1)
	printf "%s\n", ((XPV*) ($sv)->sv_any )->xpv_pv
end

