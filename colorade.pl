use Graphics::Color::RGB;
use Graphics::Color::HSV;

my $hueShift = $ARGV[2] || 0;
my $satShift = $ARGV[3] || 0;
my $valShift = $ARGV[4] || 0;

if ($hueShift < 1 and $hueShift >= 0) {
	$hueShift = $hueShift * 360;
}
if (abs($satShift) > 1) {
	$satShift = $satShift / 100;
}
if (abs($valShift) > 1) {
	$valShift = $valShift / 100;
}
print("$hueShift, $satShift, $valShift\n");

my $file = $ARGV[0];
open(FILE, $file);
my @lines = <FILE>;
close(FILE);

my $fileBase, $fileExt = GetBaseExt($file);
my $outfile = $ARGV[1] || "$fileBase-out.$fileExt";
open(FILE, ">$outfile");
foreach my $line (@lines) {
	my $offset = 0;
	while ( 1 ) {
		my $position = index($line, "#", $offset);
		last if ( $position < 0 );
		my $codePos = $position + 1;
		my $length = 6;
		my $colorCode = substr($line, $codePos, $length);
		unless (is_hex($colorCode)) {
			$length = 3;
			$colorCode = substr($colorCode, 0, $length);
		}
		if (is_hex($colorCode)) {
			my $rgb = Graphics::Color::RGB->new({0,0,0});
			$rgb = $rgb->from_hex_string($colorCode);
			if ($rgb) { 
				my $hsv = $rgb->to_hsv();
				my $h = ($hsv->hue() + $hueShift) % 360;
				my $s = $hsv->saturation() + $satShift;
				if ($s < 0) { $s = 0; }
				if ($s > 1) { $s = 1; }
				my $v = $hsv->value() + $valShift;
				if ($v < 0) { $v = 0; }
				if ($v > 1) { $v = 1; }
				# print($hsv->h(), " ", $hsv->s(), " ", $hsv->v(), " -> ");
				# print("$h, $s, $v\n");
				$hsv->hue($h);
				$hsv->saturation($s);
				$hsv->value($v);
				my $newRgb = $hsv->to_rgb();
				my $newColorCode = $newRgb->as_hex_string();
				my $replace = substr($line, $codePos, $length, $newColorCode);
				print "$colorCode, $newColorCode\n";
			} else {
				print("bad color code $colorCode\n")
			}
		}
		$offset = $position+1;
	}
	print FILE $line;
}
close(FILE);

sub GetBaseExt() {
	my $file = $_[0];
	my @dot = split(/\./, $file);
	my $ext = pop(@dot);
	my $base = join('', @dot);
	return ($base, $ext);
}

sub is_hex {
    my $self = shift if ref($_[0]); 
    my $value = shift;
    
    return unless defined $value;
    
    return if $value =~ /[^0-9a-f]/i;
    $value = lc($value);
    
    my $int = hex($value);
    return unless (defined $int);
    my $hex = sprintf "%x", $int;
    return $hex if ($hex eq $value);
    
    # handle zero stripping
    if (my ($z) = $value =~ /^(0+)/) {
        return "$z$hex" if ("$z$hex" eq $value);
    }
    
    return;
}