# baker

<?xml version="1.0" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title></title>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<link rev="made" href="mailto:" />
</head>

<body>



<ul id="index">
  <li><a href="#NAME">NAME</a></li>
  <li><a href="#SYNOPSIS">SYNOPSIS</a></li>
  <li><a href="#DESCRIPTION">DESCRIPTION</a></li>
  <li><a href="#OPTIONS">OPTIONS</a></li>
  <li><a href="#EXAMPLES">EXAMPLES</a></li>
  <li><a href="#REQUIREMENTS">REQUIREMENTS</a></li>
  <li><a href="#SEE-ALSO">SEE ALSO</a></li>
  <li><a href="#AUTHOR">AUTHOR</a></li>
  <li><a href="#COPYRIGHT">COPYRIGHT</a></li>
  <li><a href="#LICENSE">LICENSE</a></li>
</ul>

<h1 id="NAME">NAME</h1>

<p>baker - File backup assistant</p>

<h1 id="SYNOPSIS">SYNOPSIS</h1>

<pre><code>    perl baker.pl [file ...] [-timestamp=key] [-timestamp_pos=front|rear]
                  [-nofm] [-nopause]</code></pre>

<h1 id="DESCRIPTION">DESCRIPTION</h1>

<p>Back up files into respective subdirectories prefixed by &#39;bak_&#39;.</p>

<h1 id="OPTIONS">OPTIONS</h1>

<pre><code>    -timestamp=key (short term: -ts)
        d (default)
            Timestamp up to yyyymmdd
        dt
            Timestamp up to yyyymmdd_hhmm
        none
            No timestamp

    -timestamp_pos=front|rear (short term: -pos, default: rear)
        front
            Timestamping before the filename
        rear
            Timestamping after the filename

    -nofm
        The front matter will not be displayed at the beginning of the program.

    -nopause
        The shell will not be paused at the end of the program.
        Use it for a batch run.</code></pre>

<h1 id="EXAMPLES">EXAMPLES</h1>

<pre><code>    perl baker.pl oliver.eps heaviside.dat
    perl baker.pl bateman.ps -ts=d
    perl baker.pl harry_bateman.ps -ts=none</code></pre>

<h1 id="REQUIREMENTS">REQUIREMENTS</h1>

<p>Perl 5</p>

<h1 id="SEE-ALSO">SEE ALSO</h1>

<p><a href="https://github.com/jangcom/baker">baker on GitHub</a></p>

<h1 id="AUTHOR">AUTHOR</h1>

<p>Jaewoong Jang &lt;jangj@korea.ac.kr&gt;</p>

<h1 id="COPYRIGHT">COPYRIGHT</h1>

<p>Copyright (c) 2017-2019 Jaewoong Jang</p>

<h1 id="LICENSE">LICENSE</h1>

<p>This software is available under the MIT license; the license information is found in &#39;LICENSE&#39;.</p>


</body>

</html>
