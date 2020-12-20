#!/bin/bash
set -e
echo


# optional args:
#
# `clean` uses files from git (everything except web/deps),
#   so local changes won't affect the produced sfx
#
# `re` does a repack of an sfx which you already executed once
#   (grabs files from the sfx-created tempdir), overrides `clean`
#
# `no-ogv` saves ~500k by removing the opus/vorbis audio codecs
#   (only affects apple devices; everything else has native support)
#
# `no-cm` saves ~90k by removing easymde/codemirror
#   (the fancy markdown editor)


command -v gtar  >/dev/null &&
command -v gfind >/dev/null && {
	tar()  { gtar  "$@"; }
	sed()  { gsed  "$@"; }
	find() { gfind "$@"; }
	sort() { gsort "$@"; }
	unexpand() { gunexpand "$@"; }
}

[ -e copyparty/__main__.py ] || cd ..
[ -e copyparty/__main__.py ] ||
{
	echo "run me from within the project root folder"
	echo
	exit 1
}

while [ ! -z "$1" ]; do
	[ "$1" = clean  ] && clean=1  && shift && continue
	[ "$1" = re     ] && repack=1 && shift && continue
	[ "$1" = no-ogv ] && no_ogv=1 && shift && continue
	[ "$1" = no-cm  ] && no_cm=1  && shift && continue
	break
done

tmv() {
	touch -r "$1" t
	mv t "$1"
}

rm -rf sfx/*
mkdir -p sfx build
cd sfx

[ $repack ] && {
	old="$(
		printf '%s\n' "$TMPDIR" /tmp |
		awk '/./ {print; exit}'
	)/pe-copyparty"

	echo "repack of files in $old"
	cp -pR "$old/"*{jinja2,copyparty} .
	mv {x.,}jinja2 2>/dev/null || true
}

[ $repack ] || {
	echo collecting jinja2
	f="../build/Jinja2-2.6.tar.gz"
	[ -e "$f" ] ||
		(url=https://files.pythonhosted.org/packages/25/c8/212b1c2fd6df9eaf536384b6c6619c4e70a3afd2dffdd00e5296ffbae940/Jinja2-2.6.tar.gz;
		wget -O$f "$url" || curl -L "$url" >$f)

	tar -zxf $f
	mv Jinja2-*/jinja2 .
	rm -rf Jinja2-* jinja2/testsuite jinja2/_markupsafe/tests.py jinja2/_stringdefs.py
	
	f=jinja2/lexer.py
	sed -r '/.*föö.*/    raise SyntaxError/' <$f >t
	tmv $f
	
	f=jinja2/_markupsafe/_constants.py
	awk '!/: [0-9]+,?$/ || /(amp|gt|lt|quot|apos|nbsp).:/' <$f >t
	tmv $f

	# msys2 tar is bad, make the best of it
	echo collecting source
	[ $clean ] && {
		(cd .. && git archive master >tar) && tar -xf ../tar copyparty
		(cd .. && tar -cf tar copyparty/web/deps) && tar -xf ../tar
	}
	[ $clean ] || {
		(cd .. && tar -cf tar copyparty) && tar -xf ../tar
	}
	rm -f ../tar
}

ver=
git describe --tags >/dev/null 2>/dev/null && {
	git_ver="$(git describe --tags)";  # v0.5.5-2-gb164aa0
	ver="$(printf '%s\n' "$git_ver" | sed -r 's/^v//; s/-g?/./g')";
	t_ver=

	printf '%s\n' "$git_ver" | grep -qE '^v[0-9\.]+$' && {
		# short format (exact version number)
		t_ver="$(printf '%s\n' "$ver" | sed -r 's/\./, /g')";
	}

	printf '%s\n' "$git_ver" | grep -qE '^v[0-9\.]+-[0-9]+-g[0-9a-f]+$' && {
		# long format (unreleased commit)
		t_ver="$(printf '%s\n' "$ver" | sed -r 's/\./, /g; s/(.*) (.*)/\1 "\2"/')"
	}

	[ -z "$t_ver" ] && {
		printf 'unexpected git version format: [%s]\n' "$git_ver"
		exit 1
	}

	dt="$(git log -1 --format=%cd --date=format:'%Y,%m,%d' | sed -E 's/,0?/, /g')"
	printf 'git %3s: \033[36m%s\033[0m\n' ver "$ver" dt "$dt"
	sed -ri '
		s/^(VERSION =)(.*)/#\1\2\n\1 ('"$t_ver"')/;
		s/^(S_VERSION =)(.*)/#\1\2\n\1 "'"$ver"'"/;
		s/^(BUILD_DT =)(.*)/#\1\2\n\1 ('"$dt"')/;
	' copyparty/__version__.py
}

[ -z "$ver" ] && 
	ver="$(awk '/^VERSION *= \(/ {
		gsub(/[^0-9,]/,""); gsub(/,/,"."); print; exit}' < copyparty/__version__.py)"

ts=$(date -u +%s)
hts=$(date -u +%Y-%m%d-%H%M%S) # --date=@$ts (thx osx)

mkdir -p ../dist
sfx_out=../dist/copyparty-sfx

echo cleanup
find .. -name '*.pyc' -delete
find .. -name __pycache__ -delete

# especially prevent osx from leaking your lan ip (wtf apple)
find .. -type f \( -name .DS_Store -or -name ._.DS_Store \) -delete
find .. -type f -name ._\* | while IFS= read -r f; do cmp <(printf '\x00\x05\x16') <(head -c 3 -- "$f") && rm -f -- "$f"; done

echo use smol web deps
rm -f copyparty/web/deps/*.full.*

# it's fine dw
grep -lE '\.full\.(js|css)' copyparty/web/* |
while IFS= read -r x; do
	sed -r 's/\.full\.(js|css)/.\1/g' <"$x" >t
	tmv "$x"
done

[ $no_ogv ] &&
	rm -rf copyparty/web/deps/{dynamicaudio,ogv}*

[ $no_cm ] && {
	rm -rf copyparty/web/mde.* copyparty/web/deps/easymde*
	echo h > copyparty/web/mde.html
	f=copyparty/web/md.html
	sed -r '/edit2">edit \(fancy/d' <$f >t && tmv "$f"
}

# up2k goes from 28k to 22k laff
echo entabbening
find | grep -E '\.(js|css|html|py)$' | while IFS= read -r f; do
	unexpand -t 4 --first-only <"$f" >t
	tmv "$f"
done

echo creating tar
args=(--owner=1000 --group=1000)
[ "$OSTYPE" = msys ] &&
	args=()

tar -cf tar "${args[@]}" --numeric-owner copyparty jinja2

echo compressing tar
# detect best level; bzip2 -7 is usually better than -9
for n in {2..9}; do cp tar t.$n; bzip2 -$n t.$n & done; wait; mv -v $(ls -1S t.*.bz2 | tail -n 1) tar.bz2
for n in {2..9}; do cp tar t.$n;  xz -ze$n t.$n & done; wait; mv -v $(ls -1S t.*.xz  | tail -n 1) tar.xz
rm t.*

echo creating unix sfx
(
	sed "s/PACK_TS/$ts/; s/PACK_HTS/$hts/; s/CPP_VER/$ver/" <../scripts/sfx.sh |
	grep -E '^sfx_eof$' -B 9001;
	cat tar.xz
) >$sfx_out.sh

echo creating generic sfx
python ../scripts/sfx.py --sfx-make tar.bz2 $ver $ts
mv sfx.out $sfx_out.py
chmod 755 $sfx_out.*

printf "done:\n"
printf "  %s\n" "$(realpath $sfx_out)."{sh,py}
# rm -rf *

# tar -tvf ../sfx/tar | sed -r 's/(.* ....-..-.. ..:.. )(.*)/\2 `` \1/' | sort | sed -r 's/(.*) `` (.*)/\2 \1/'| less
# for n in {1..9}; do tar -tf tar | grep -vE '/$' | sed -r 's/(.*)\.(.*)/\2.\1/' | sort | sed -r 's/([^\.]+)\.(.*)/\2.\1/' | tar -cT- | bzip2 -c$n | wc -c; done 
