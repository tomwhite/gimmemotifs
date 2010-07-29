#!@WHICHPERL@
##
## $Id:$
##
## $Log:$
## $Rev: $
##
# Author: Timothy Bailey

#$debug = 1;                     # uncomment to debug this script

use lib qw(@PERLLIBDIR@);
use Globals;
use Validation;
use CGI qw/:standard/;          # use the CGI package
use SOAP::Lite;
use MIME::Base64;
use OpalServices;
use OpalTypes;
require "Utils.pm";

# get the directories using the new installation scheme
$dir = "@MEME_DIR@";		# installed directory
$logs = "$dir/LOGS";		# directory for temp files
$bin = "$dir/bin";		# directory for executables 
$service_url = "@OPAL@/GLAM2_@S_VERSION@";
#$email_contact = "&#x67;&#108;&#x61;&#x6d;&#50;&#x40;&#105;&#x6d;&#x62;&#x2e;&#117;&#x71;&#46;&#101;&#100;&#x75;&#46;&#97;&#117;";
$email_contact = '@contact@';

# defaults
$PROGRAM = "GLAM2";
$NERRORS = 0; 			# no errors yet

# limits
$MINSEQS = 2;
$MINCOLS = 2;
$MAXCOLS = 300;
$MINREPS = 1;
$MAXREPS = 100;
$MINITER = 1;
$MAXITER = 1000000;
$MINPSEU = 0;

# get the parameters for the query
get_params();

# if there is no action specified, print an input form
if (! $action) {
  print_form();
} else {
  check_params();
  submit() unless $NERRORS;
  print_tailers();
}

################################################################################# 
# Subroutines
#
################################################################################

#
# print the glam2 input form
#
sub print_form
{

  my $action = "glam2.cgi";
  my $logo = "../doc/images/glam2_logo.png";
  my $alt = "$PROGRAM logo";
  my $form_description = qq {
Use this form to submit DNA or protein sequences to $PROGRAM.
$PROGRAM will analyze your sequences for <B>gapped</B> motifs.
  }; # end quote

  #
  # print the sequence input fields unless sequences already input
  #
  my $req_left;
  if (! $data) {
    #
    # required left side: sequences fields
    #
    my $seq_doc = "../help_sequences.html#sequences";
    my $alpha_doc = "../help_alphabet.html";
    my $format_doc = "../help_format.html";
    my $filename_doc = "../help_sequences.html#filename";
    my $paste_doc = "../help_sequences.html#actual-sequences";
    my $sample_file = "../examples/At.fa";
    my $sample_alphabet = "Protein";
    $req_left = make_upload_sequences_field("datafile", "data", $MAXDATASET,
      $seq_doc, $alpha_doc, $format_doc, $filename_doc, $paste_doc, 
      $sample_file, $sample_alphabet, $target);
  } else {
    $req_left = qq {
<H3>$PROGRAM will analyze your previously provided sequences.</H3>
<INPUT TYPE="hidden" NAME="data" VALUE="$data">
    }; # end quote
  }

  #
  # required right side: email, embed
  #

  my $req_right = make_address_field($address, $address_verify);
  $req_right .= "<BR>\n";
  my $text = qq {
<B>Embed</B> the input sequences in the HTML results so 
that your query can be easily resubmitted and modified. 
This will increase the size of your output HTML file 
substantially if your sequence data is large!
  }; # end quote
  $req_right .= make_checkbox("embed_seqs", 1, $text, 1);

  # finish required fields
  my $required = make_input_table("Required", $req_left, $req_right);

  #
  # optional fields
  #

  # optional left: description, limits
  my $descr = "sequences";
  my $opt_left = make_description_field($descr, $description);

  # limits fields
  $opt_left .= qq {
<BR>
<BR>
<INPUT class="maininput" TYPE="TEXT" SIZE="6" NAME="-z" VALUE="$min_seqs">
<B>Minimum</B> number of <B>sequences</B> in the alignment (>=$MINSEQS) 
<BR>
<BR>
<INPUT class="maininput" TYPE="TEXT" SIZE="6" NAME="-a" VALUE="$min_cols">
<A HREF="../help_width.html#aligned_cols"><B>Minimum</B></A> number of aligned <B>columns</B> (>=$MINCOLS) 
<BR>
<INPUT class="maininput" TYPE="TEXT" SIZE="6" NAME="-b" VALUE="$max_cols">
<A HREF="../help_width.html#aligned_cols"><B>Maximum</B></A> number of aligned <B>columns</B> (<=$MAXCOLS) 
<BR>
<INPUT class="maininput" TYPE="TEXT" SIZE="6" NAME="-w" VALUE="$ini_cols">
<A HREF="../help_width.html#aligned_cols"><B>Initial</B></A> number of aligned <B>columns</B> 
<BR>
<BR>
<INPUT class="maininput" TYPE="TEXT" SIZE="6" NAME="-r" VALUE="$nreps">
<B>Number</B> of alignment <B>replicates</B> (<=$MAXREPS) 
<BR>
<INPUT class="maininput" TYPE="TEXT" SIZE="6" NAME="-n" VALUE="$niter" $niter_attr>
<B>Maximum</B> number of <B>iterations</B> without improvement (<=$MAXITER)
<BR>
  }; # end quote

  # optional right fields: pseudocounts, shuffle, dna-only
  my $opt_right = qq {
<INPUT class="maininput" TYPE="TEXT" SIZE="6" NAME="-D" VALUE="$del_pseu">
<B>Deletion</B> pseudocount (>$MINPSEU)
<BR>
<INPUT class="maininput" TYPE="TEXT" SIZE="6" NAME="-E" VALUE="$no_del_pseu">
<B>No-deletion</B> pseudocount (>$MINPSEU)
<BR>
<INPUT class="maininput" TYPE="TEXT" SIZE="6" NAME="-I" VALUE="$ins_pseu">
<B>Insertion</B> pseudocount (>$MINPSEU)
<BR>
<INPUT class="maininput" TYPE="TEXT" SIZE="6" NAME="-J" VALUE="$no_ins_pseu">
<B>No-insertion</B> pseudocount (>$MINPSEU)
<BR>
<BR>
  }; # end quote
  my $doc = "../help_sequences.html#shuffle";
  my $text = "<A HREF='$doc'><B>Shuffle</B></A> sequence letters";
  $opt_right .= make_checkbox("shuffle", 1, $text, 0);

  # DNA-ONLY options
  if (!defined $alphabet || $alphabet eq "n") {
    my $text = "<B>Examine both strands</B> - forward and reverse complement";
    my $options = make_checkbox("-2", 1, $text, 1);
    $opt_right .= make_dna_only($options);
  }

  # finish optional part
  my $optional = make_input_table("Optional", $opt_left, $opt_right);

  #
  # print final form
  #
  my $form = make_submission_form(
    make_form_header($PROGRAM, "Submission form"),
    make_submission_form_top($action, $logo, $alt, $form_description),
    $required,
    $optional,
    make_submit_button("Start search", $email_contact),
    make_submission_form_bottom(),
    make_submission_form_tailer()
  );
  print "Content-Type: text/html\n\n$form";

} # print_form

#
# get parameters from the input
#
sub get_params
{
  # command options
  $options = "";
  $dna_options = "";

  # retrieve the fields from the form
  $action = param('target_action');
  $address = param('address');
  $address_verify = param('address_verify');
  $description = param('description');
  $datafile_name = param('datafile');
  $data = param('data');
  $min_seqs = param('-z') ? param('-z') : 2; $options .= " -z $min_seqs" if $min_seqs;
  $min_cols = param('-a') ? param('-a') : 2; $options .= " -a $min_cols" if $min_cols;
  $max_cols = param('-b') ? param('-b') : 50; $options .= " -b $max_cols" if $max_cols;
  $ini_cols = param('-w') ? param('-w') : 20; $options .= " -w $ini_cols" if $ini_cols;
  $nreps = param('-r') ? param('-r') : 10; $options .=    " -r $nreps" if $nreps;
  $niter = param('-n') ? param('-n') : 2000; $options .=    " -n $niter" if $niter;
  $niter_attr = param('-n_attributes') ? param('-n_attributes') : "";
  $del_pseu = param('-D') ? param('-D') : 0.1; $options .= " -D $del_pseu" if $del_pseu;
  $no_del_pseu = param('-E') ? param('-E') : 2.0; $options .= " -E $no_del_pseu" if $no_del_pseu;
  $ins_pseu = param('-I') ? param('-I') : 0.02; $options .= " -I $ins_pseu" if $ins_pseu;
  $no_ins_pseu = param('-J') ? param('-J') : 1.0; $options .= " -J $no_ins_pseu" if $no_ins_pseu;

  $both_str = param('-2'); $dna_options .= " -2" if $both_str;

  $shuffle = param('shuffle'); $shuffle = 0 unless ($shuffle);
  $embed_seqs = param('embed_seqs');

} # get_params

#
# Check the parameters on the form.
#
sub check_params
{

  # change working directory to LOGS
  chdir($logs) || &whine("Can't cd to $logs");

  # check that valid email address was provided
  check_address($address, $email_contact);

  # check description field
  check_description($description);

  # get FASTA sequences and information about them
  ($fasta_data, $alphabet, $nseqs, $min, $max, $ave, $total)
    = get_sequence_data($data, $datafile_name, $MAXDATASET, $shuffle);

  # check min_seqs
  if ($nseqs > 0 && ($min_seqs < $MINSEQS || $min_seqs > $nseqs)) {
    &whine("
       You must specify <I>Minimum number of sequences in the alignment</I> between
       $MINSEQS and the number of sequences in your dataset ($nseqs), inclusive.
    ");
  }

  # check min/max/intial numbers of columns
  if ($min_cols < $MINCOLS || $min_cols > $MAXCOLS) {
    &whine("
       You must specify <I>Minimum number of aligned columns</I> 
       between $MINCOLS and $MAXCOLS, inclusive.
    ");
  }
  if ($max_cols < $MINCOLS || $max_cols > $MAXCOLS) {
    &whine("
       You must specify <I>Maximum number of aligned columns</I> 
       between $MINCOLS and $MAXCOLS, inclusive.
    ");
  }
  if ($ini_cols < $MINCOLS || $ini_cols > $MAXCOLS) {
    &whine("
       You must specify <I>Initial number of aligned columns</I> ($ini_cols)
       between $MINCOLS and $MAXCOLS, inclusive.
    ");
  }
  if ($max_cols < $min_cols) {
    &whine("
       You must specify <I>Minimum number of aligned columns</I> 
       no greater than the <I>Maximum number of aligned columns</I>.
    ");
  }
  if ($ini_cols < $min_cols || $ini_cols > $max_cols) {
    &whine("
       You must specify <I>Initial number of aligned columns</I> ($ini_cols)
       between
       the <I>Minimum number of aligned columns</I> ($min_cols),
       and the <I>Maximum number of aligned columns</I> ($max_cols), inclusive.
    ");
  }

  # check number of replicates and iterations
  if ($nreps < $MINREPS || $nreps > $MAXREPS) {
    &whine("
       You must specify <I>Number of alignment replicates</I> ($nreps)
       between $MINREPS and $MAXREPS, inclusive.
    ");
  }
  if ($niter < $MINITER || $niter > $MAXITER) {
    &whine("
       You must specify <I>Number of alignment iterations without improvement</I> ($niter)
       between $MINITER and $MAXITER, inclusive.
    ");
  }

  # check that pseudocounts are OK
  if ($del_pseu <= $MINPSEU) {
    &whine("
       You must specify <I>Deletion pseudocount</I> ($del_pseu)
       greater than $MINPSEU.
    ");
  }
  if ($no_del_pseu <= $MINPSEU) {
    &whine("
       You must specify <I>No-deletion pseudocount</I> ($no_del_pseu)
       greater than $MINPSEU.
    ");
  }
  if ($ins_pseu <= $MINPSEU) {
    &whine("
       You must specify <I>Insertion pseudocount</I> ($ins_pseu)
       greater than $MINPSEU.
    ");
  }

  # remove spaces, non-ASCII and single quotes from $datafile_name
  $datafile_name = "pasted sequences" unless($datafile_name); 
  $datafile_name =~ s/[ \'\x80-\xFF]/\_/g;

  # convert alphabet to GLAM2 flag n/p
  $alphabet = ($alphabet eq "DNA") ? "n" : "p";

  # add dna options if alphabet permits
  $options .= $dna_options if ($alphabet eq "n");

  # finish GLAM2 argument list
  $args = "$options $alphabet sequences";

} # check_params

#
# send the headers for a response
#
sub printheaders {
print <<END; 
Content-type: text/html

<HTML>
<TITLE> $PROGRAM - Verification </TITLE>
<BODY BACKGROUND=\"../images/bkg.jpg\">
<HR>
END
}

#
# Submit job to webservice via OPAL
#
sub submit
{
  $service = OpalServices->new(service_url => $service_url);

  #
  # start OPAL requst
  #
  $req = JobInputType->new();
  $req->setArgs($args);

  #
  # create list of OPAL file objects
  #
  @infilelist = ();
  # 1) Sequence file
  $inputfile = InputFileType->new("sequences", $fasta_data);
  push(@infilelist, $inputfile);
  $inputfile = InputFileType->new("address", $address);
  push(@infilelist, $inputfile);
  $inputfile = InputFileType->new("description", $description);
  push(@infilelist, $inputfile);
  if ($embed_seqs) {
    $inputfile = InputFileType->new("embed_seqs", "");
    push(@infilelist, $inputfile);
  }
  # Email address file (for logging purposes only)
  $inputfile = InputFileType->new("address_file", $address);
  push(@infilelist, $inputfile);
  # Submit time file (for logging purposes only)
  $inputfile = InputFileType->new("submit_time_file", `date -u '+%d/%m/%y %H:%M:%S'`);
  push(@infilelist, $inputfile);

  # Add file objects to request
  $req->setInputFile(@infilelist);

  # Submit the request to OPAL
  $result = $service->launchJob($req);

  # Give user the verification form and email message
  $verify = make_verification();
  verify_opal_job($result, $address, $email_contact, $verify);
} # submit

#
# make the verification message in HTML
#
sub make_verification
{
  my $content = "<HR> <UL>\n";

  $content .= "<LI> Description:<B> $description </B>\n" if $description;
  $content .= "<LI> Sequence file:<B> $datafile_name </B>\n";
  $content .= "<LI> <B>Shuffling</B> letters in input sequences\n" if $shuffle;
  $content .= "
    <LI> Statistics on your dataset:
      <TABLE BORDER>
	<TR> <TD> type of sequence <TH ALIGN=RIGHT> $alphabet
	<TR> <TD> number of sequences <TH ALIGN=RIGHT> $nseqs
	<TR> <TD> shortest sequence (residues) <TH ALIGN=RIGHT> $min
	<TR> <TD> longest sequence (residues) <TH ALIGN=RIGHT> $max
	<TR> <TD> average sequence length (residues) <TH ALIGN=RIGHT> $ave
	<TR> <TD> total dataset size (residues) <TH ALIGN=RIGHT> $total
      </TABLE>
    </UL>
  ";

  return($content);

} # make_verification