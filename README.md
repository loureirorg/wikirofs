# WikiroFS

Wikiro is a virtual filesystem designed to mount Wikipedia in your filesystem.

## Installation

```bash
> sudo su
> gem install wikirofs
```

## Usage
```bash
# mount (eg. in /mnt/test)
> mount.wikiro /mnt/test

# default wikis
> ls /mnt/test
wikipedia-ceb
wikipedia-de
wikipedia-en
wikipedia-es
...

# main articles
> ls /mnt/test/wikipedia-en
Abacus.txt
Abiogenesis.txt
Abolitionism.txt
Abortion.txt
...

# not listed wikis
> mkdir /mnt/test/wikipedia-simple
> ls /mnt/test/wikipedia-simple
Abraham_Lincoln.txt
Acceleration.txt
Acid.txt
Adam_Smith.txt
...

# view article (even if it's not listed)
> cat /mnt/test/wikipedia-en/Moon.txt
{{about |Earths natural satellite |moons in general |Natural satellite |other uses}}
{{pp-semi-protected |small=yes}}
{{pp-move-indef}}
{{Use dmy dates|date=January 2017}}
...

# remove a wiki from the list (it doesn't affect the real Wikipedia)
> rmdir /mnt/test/wikipedia-ceb
> ls /mnt/test
wikipedia-ceb
wikipedia-de
wikipedia-en
...

# remove article from the list (it doesn't affect the real Wikipedia)
> rm /mnt/test/wikipedia-en/Abacus.txt
> ls /mnt/test/wikipedia-en
Abiogenesis.txt
Abolitionism.txt
Abortion.txt
...

# umount
> sudo umount /mnt/test
```

<!-- ## Mounting on boot
1. edit your /etc/fstab
2. add something like this:
```
/usr/sbin/mount.wikiro /mnt/test fuse user,noauto    0    0
```
 -->

## Compiling (with rb2exe)

```bash
> sudo su
> rb2exe main.rb --add=. --daemon -o mount.wikiro
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/loureirorg/wikirofs.
