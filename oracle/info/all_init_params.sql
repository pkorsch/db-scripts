select par.ksppinm  name,
       val.ksppstvl value,
       val.ksppstdf def_val
from   x$ksppi  par,
       x$ksppcv val
where  par.indx=val.indx
order by 1;
