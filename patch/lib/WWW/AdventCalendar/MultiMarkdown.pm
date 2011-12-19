package WWW::AdventCalendar::MultiMarkdown;
use 5.010;
use strict;
use warnings;
use base qw(Text::MultiMarkdown);

our $VERSION = '0.000001';
$VERSION = eval $VERSION;

sub _DoCodeBlocks {

    #
    # Process Markdown code blocks (indented with 4 spaces or 1 tab):
    # * outdent the spaces/tab
    # * encode <, >, & into HTML entities
    # * escape Markdown special characters into MD5 hashes
    # * trim leading and trailing newlines
    #
    my ( $self, $text ) = @_;

    $text =~ s{
        (?:\n\n|\A)
        (                # $1 = the code block -- one or more lines, starting with a space/tab
          (?:
            (?:[ ]{$self->{tab_width}} | \t)   # Lines must start with a tab or a tab-width of spaces
            .*\n+
          )+
        )
        ((?=^[ ]{0,$self->{tab_width}}\S)|\Z)    # Lookahead for non-space at line-start, or end of doc
    }{
        my $codeblock = $1;
        my $result;  # return value

        $codeblock = $self->_EncodeCode($self->_Outdent($codeblock));
        $codeblock = $self->_Detab($codeblock);
        $codeblock =~ s/\A\n+//;  # trim leading newlines
        $codeblock =~ s/\n+\z//;  # trim trailing newlines

        my $brush;
        given ($codeblock) {
            when ( /^\s*#!bash$/ism       ) { $brush = 'bash'    }
            when ( /^\s*#!cpp$/ism        ) { $brush = 'cpp'     }
            when ( /^\s*#!diff$/ism       ) { $brush = 'diff'    }
            when ( /^\s*#!ini$/ism        ) { $brush = 'ini'     }
            when ( /^\s*#!java$/ism       ) { $brush = 'java'    }
            when ( /^\s*#!javascript$/ism ) { $brush = 'jscript' }
            when ( /^\s*#!perl$/ism       ) { $brush = 'perl'    }
            when ( /^\s*#!plain$/ism      ) { $brush = 'plain'   }
            when ( /^\s*#!sql$/ism        ) { $brush = 'sql'     }
            when ( /^\s*#!xml$/ism        ) { $brush = 'xml'     }
            when ( /^\s*#!yaml$/ism       ) { $brush = 'yaml'    }
        }

        if ($brush) {
            if ($codeblock =~ m/^(\s+)/) {
                my $len = length $1;
                $codeblock =~ s/^ {$len}//gsm;
                $codeblock =~ s/^#!.*?\n//;
                $result = qq{\n\n<pre class="brush: $brush;">\n} . $codeblock . "\n</pre>\n\n";
            }
            else {
                $result = "\n\n<pre><code>" . $codeblock . "\n</code></pre>\n\n";
            }
        }
        else {
            $result = "\n\n<pre><code>" . $codeblock . "\n</code></pre>\n\n";
        }

        $result;
    }egmx;

    return $text;
}
