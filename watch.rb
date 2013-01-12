#!/usr/bin/env ruby
require 'fileutils'
require 'rainbow'
require 'filemagic'

# "THE BEER-WARE LICENSE" (Revision 42):
# <sebastian.benque@gmail.com> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return Sebastian Benuqe

# This program is there to help you mark movies/songs as watched/listen so that
# you can easily find unwatched/-listened files on your computer.

# Changelog: 
# * 02/01/2013 - v0.1
# * 03/01/2013 - Added functionality for list of files.
# * 12/01/2013 - Added colorfull output.

# Config
###

$media_types = ['avi', 'audio', 'mpeg', 'mp3']
$text_types  = ['latex', 'text']

def puts_dir(n)   puts n.color :white end
def puts_media(n) puts n.color :red end
def puts_pdf(n)   puts n.color :blue end
def puts_text(n)  puts n.color :magenta end

# Helpers
###

# Remove all files from the list l that are hidden files(".*"), upper dir (..)
# or current directory (".").
def proper_files(l)
  l.delete_if { |f| f[0,1] == "." }
end 

# Apply the flags with chmod to all files in the list.
def chmod_list(list, flags)
  list.map { |f| FileUtils.chmod flags, f }
end

# Create a list of all files in the current working directory, that are
# proper(following the definition in the function proper_files).
def files
  proper_files(Dir.entries(Dir.pwd))
end

# Print output in color. For different filetypes will it use different colors
# defined in the Config section of the source code. 
def puts_colors(l)
  fm = FileMagic.new
  meta = fm.file(l).downcase

  case 
    when meta.include?('directory') 
      then puts_dir l
    when meta.include?('pdf') 
      then puts_pdf l
    when $media_types.any? { |s| meta.include? s }
      then puts_media l
    when $text_types.any? { |s| meta.include? s }
      then puts_text l
    else puts l
  end
end

# Functions to be called by the user
###
def mark_watched(fns)
  chmod_list fns, "+t" 
end

def mark_unwatched(fns)
  chmod_list fns, "-t"
end

def list_watched
  files.delete_if { |f| not File.stat(f).sticky? }.map { |n| puts_colors n }
end

def list_unwatched
  files.delete_if { |f| File.stat(f).sticky? }.map { |n| puts_colors n }
end

# Control Structures
###
def handle_args(args)
  case
    # Mark as watched
    when args.length >= 2 && args[0] == "-w" 
      then mark_watched args[1..-1] 
    # Unmark watched movie
    when args.length >= 2 && args[0] == "-u" 
      then mark_unwatched args[1..-1]
    # List watched movies
    when args.length == 1 && args[0] == "-lw" 
      then list_watched
    # List unwatched movies
    when args.length == 1 && args[0] == "-lu" 
      then list_unwatched
    else usage 
  end
end

def usage
  puts "#{$0} -w <movie names>"
  puts "marks the movies as watched.\n\n"
  puts "#{$0} -u <movie names>"
  puts "marks the movies as unwatched.\n\n"
  puts "#{$0} -lw"
  puts "list all watched movies.\n\n"
  puts "#{$0} -lu"
  puts "list alle unwatched movies."
end

# Main
###

handle_args(ARGV)

