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
    printf("%20-s %10-s %20-s %15-s %15-s %80-s %s \n", "[time]", "[probemod]", "[probefunc]", "[probename]", "[execname]", "[path]", "[exit code]");
}

END
{
    printf("Finished.\n");
}

syscall::unlink:entry
{
    self->me = 1;
    self->file = copyinstr(arg0);
    self->unlinkat = 0;
    printf("unlink: %s\n", self->file);
}

syscall::unlinkat:entry
{
    self->me = 1;
    self->file = copyinstr(arg1);
    self->unlinkat = 1;
    printf("unlinkat: %s\n", self->file);
}


fsinfo:::remove,rmdir 
/self->me == 1 && self->unlinkat == 0/ 
{
    printf("%Y %10-s %20-s %15-s %15-s %80-s %d \n", walltimestamp, probemod, probefunc, probename, execname, self->file, args[1]);
}

fsinfo:::remove
/self->me == 1 && self->unlinkat == 1/ 
{
    self->dir = args[0]->fi_pathname;
    printf("%Y %10-s %20-s %15-s %15-s dir:%s path:%80-s %d \n", walltimestamp, probemod, probefunc, probename, execname, self->dir, self->file, args[1]);
}


fsinfo:::rmdir 
/self->me == 1 && self->unlinkat == 1/ 
{
    self->dir = args[0]->fi_pathname;
    printf("%Y %10-s %20-s %15-s %15-s %s/%80-s %d \n", walltimestamp, probemod, probefunc, probename, execname, self->dir, self->file, args[1]);
}


syscall::unlink*:return
/self->me == 1/
{
    self->me = 0;
    self->file = 0;
    self->unlinkat = 0;
}

