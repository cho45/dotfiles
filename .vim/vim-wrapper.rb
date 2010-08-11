#!/usr/bin/env ruby

=begin
/*
 * Block zero holds all info about the swap file.
 *
 * NOTE: DEFINITION OF BLOCK 0 SHOULD NOT CHANGE! It would make all existing
 * swap files unusable!
 *
 * If size of block0 changes anyway, adjust MIN_SWAP_PAGE_SIZE in vim.h!!
 *
 * This block is built up of single bytes, to make it portable across
 * different machines. b0_magic_* is used to check the byte order and size of
 * variables, because the rest of the swap file is not portable.
 */
struct block0
{
    char_u	b0_id[2];	/* id for block 0: BLOCK0_ID0 and BLOCK0_ID1 */
    char_u	b0_version[10];	/* Vim version string */
    char_u	b0_page_size[4];/* number of bytes per page */
    char_u	b0_mtime[4];	/* last modification time of file */
    char_u	b0_ino[4];	/* inode of b0_fname */
    char_u	b0_pid[4];	/* process id of creator (or 0) */
    char_u	b0_uname[B0_UNAME_SIZE]; /* name of user (uid if no name) */
    char_u	b0_hname[B0_HNAME_SIZE]; /* host name (if it has a name) */
    char_u	b0_fname[B0_FNAME_SIZE_ORG]; /* name of file being edited */
    long	b0_magic_long;	/* check for byte order of long */
    int		b0_magic_int;	/* check for byte order of int */
    short	b0_magic_short;	/* check for byte order of short */
    char_u	b0_magic_char;	/* check for last char */
};
=end

require "pathname"
ENV["PERL5LIB"] = ENV["PERL5LIB"].split(/:/).unshift('t/lib').join(':')
VIM = "/usr/local/vim7/bin/vim"
#VIM = "/usr/bin/vim"

begin
	swap = Pathname.new("~/.vimrc").expand_path.read[/set directory=(.+)/, 1]
	swap = Pathname.new(swap).expand_path

	# not consider byte order

	MAGIC = "b0"

	target = Pathname.new(ARGV[0]).realpath
	swap   = "#{swap + target.basename}.swp"

	fname, pid = File.open(swap) { |f|
		raise "not swap" unless f.read(2) == MAGIC
		version   = f.read(10).unpack("A*")
		page_size = f.read(4)
		mtime     = f.read(4).unpack("L")[0]
		inode     = f.read(4).unpack("L")[0]
		pid       = f.read(4).unpack("L")[0]
		uname     = f.read(40).unpack("A*")[0]
		hname     = f.read(40).unpack("A*")[0]
		fname     = f.read(898).unpack("A*")[0]
		[fname, pid]
	}

	raise "swap not found" unless pid
	raise "swap not found" unless target.realpath == Pathname.new(fname).expand_path.realpath

	winnum = `pid2screen #{pid}`.strip

	raise "window not found" if winnum.empty?

	if winnum == ENV['WINDOW']
		warn "vim may be run on background, try fg"
		File.open("/tmp/screen-tty", "w") {|f| f.puts "fg" }
		system "screen", "-X", "readbuf", "/tmp/screen-tty"
		system "screen", "-X", "paste", "."
		exit 1
	else
		exec "screen", "-X", "select", winnum
	end

rescue
	exec VIM, *ARGV
end

