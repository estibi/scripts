#!/usr/sbin/dtrace -s

/*
 * Sledzi usuniecia plikow w systemie.
 *
 */

# pragma D option quiet
# pragma D option switchrate=10
# pragma D option bufsize=32m

BEGIN
{
    printf("%10-s %20-s %15-s %15-s %80-s %s \n", "[probemod]", "[probefunc]", "[probename]", "[execname]", "[path]", "[exit code]");
}

END
{
    printf("Finished.\n");
}

fsinfo:::lookup
{
    self->me = 1;
    self->path = args[0]->fi_pathname;
}

fsinfo:::remove,rmdir 
/self->me == 1/ 
{
    printf("%10-s %20-s %15-s %15-s %80-s %d \n", probemod, probefunc, probename, execname, self->path, args[1]);
    self->me = 0;
    self->path = 0;
}


