#!/usr/bin/perl
#usage: to interget liner circ and fusion
#
#
use strict;
use warnings;
use File::Basename;
use Getopt::Long;

my ($afile,$bfile,$cfile,$outdir);
GetOptions(
    "afile|A=s" => \$afile,
	"bfile|B=s" => \$bfile,
	"cfile|C=s" => \$cfile,
	"outdir|O=s" => \$outdir,
	
);
	open JU,"< $afile" or die"$!";
	<JU>;
	my %liner_right;
	my %liner_left;
	my %refliner;
	while(<JU>){
	s/\s+$//;
	 my @tmp=split/\t/;
	 my @jc=split/:/,$tmp[0];
	 my @jc2=split/\|/,$jc[1];
	 my $chr=$jc[0];
	 my $stand=$jc[2];
	 my $st=$jc2[0];
	 my $ed=$jc2[1];
	 my $post_left=join("_",$chr,$st,$stand);
	 my $post_right=join("_",$chr,$ed,$stand);
	 my $id=join("_",$chr,$st,$ed,$stand);
	 $refliner{$id}=$tmp[6];
	 $liner_left{$post_left}{"circ"}="NA";
	 $liner_right{$post_right}{"circ"}="NA";
	 $liner_left{$post_left}{"fusion"}="NA";
	 $liner_right{$post_right}{"fusion"}="NA";
	 
	}
	open CIR,"< $bfile" or die"$!";
	<CIR>;
	my %circ_rest;
	while(<CIR>)
	{
		s/\s+$//;
		my @tmp=split/\t/,$_;
		my @cir=split/_/,$tmp[0];
		my $cir_count=0; ##是否与线性的有交集
		
		my $circ_left=join("_",$cir[0],$cir[1],$cir[3]);
		my $circ_right=join("_",$cir[0],$cir[2],$cir[3]);
		if(exists $liner_right{$circ_left}){ ### circ的左端
			$cir_count=$cir_count+1;
			my $pre=$liner_right{$circ_left}{"circ"};
			my @preArr=split/;/,$pre;
			if($#preArr==0){
			$liner_right{$circ_left}{"circ"}=$tmp[0];
			}
			else{
			my $new=join(";",$pre);
			$liner_right{$circ_left}{"circ"}=$new;
			}
			
		
		}
		if(exists $liner_left{$circ_right}){ ### circ的右端
			$cir_count=$cir_count+1;
			my $pre=$liner_left{$circ_right}{"circ"};
			my @preArr=split/;/,$pre;
			if($#preArr==0){
			$liner_left{$circ_right}{"circ"}=$tmp[0];
			}
			else{
			my $new=join(";",$pre);
			$liner_left{$circ_right}{"circ"}=$new;
			}
			}
		if($cir_count==0){
			my $c_gene="NA";
			if ($tmp[5] =~ /gene_name (\S+);?/) {
			$c_gene = $1;
            $c_gene =~ s/[\"\']//g;
			}
			$circ_rest{$tmp[0]}=$c_gene;
		}
		
		
		
	}

	open FUS,"< $cfile" or die"$!";
	<FUS>;
	my %fus_rest;
	while(<FUS>)
	{
		s/\s+$//;
		my @tmp=split/\t/,$_;
		my @fu=split/_/,$tmp[0];
		my $fu_count=0; ##是否与线性的有交集
		
		my $fu_left=join("_",$fu[0],$fu[1],$fu[2]);
		my $fu_right=join("_",$fu[3],$fu[4],$fu[5]);
		## 与back.pl 中的一致
		
		if(exists $liner_right{$fu_right}){ ### circ的左端
			$fu_count=$fu_count+1;
			my $pre=$liner_right{$fu_right}{"fusion"};
			my @preArr=split/;/,$pre;
			if($#preArr==0){
			$liner_right{$fu_right}{"fusion"}=$tmp[0];
			}
			else{
			my $new=join(";",$pre);
			$liner_right{$fu_right}{"fusion"}=$new;
			}
			
		
		}
		if(exists $liner_left{$fu_left}){ ### circ的右端
			$fu_count=$fu_count+1;
			my $pre=$liner_left{$fu_left}{"fusion"};
			my @preArr=split/;/,$pre;
			if($#preArr==0){
			$liner_left{$fu_left}{"fusion"}=$tmp[0];
			}
			else{
			my $new=join(";",$pre);
			$liner_left{$fu_left}{"fusion"}=$new;
			}
			}		
		
		if(exists $liner_right{$fu_left}){ ### circ的左端
			$fu_count=$fu_count+1;
			my $pre=$liner_right{$fu_left}{"fusion"};
			my @preArr=split/;/,$pre;
			if($#preArr==0){
			$liner_right{$fu_left}{"fusion"}=$tmp[0];
			}
			else{
			my $new=join(";",$pre);
			$liner_right{$fu_left}{"fusion"}=$new;
			}
			
		
		}
		if(exists $liner_left{$fu_right}){ ### circ的右端
			$fu_count=$fu_count+1;
			my $pre=$liner_left{$fu_right}{"fusion"};
			my @preArr=split/;/,$pre;
			if($#preArr==0){
			$liner_left{$fu_right}{"fusion"}=$tmp[0];
			}
			else{
			my $new=join(";",$pre);
			$liner_left{$fu_right}{"fusion"}=$new;
			}
			}
		if($fu_count==0){
			my $left_gene="NA";
			my $right_gene="NA";
			if ($tmp[7] =~ /gene_name:(\S+);?/) {
			$left_gene = $1;
            $left_gene =~ s/;//g;
			}
			if ($tmp[9] =~ /gene_name:(\S+);?/) {
			$right_gene = $1;
            $right_gene =~ s/;//g;
			}
			$fus_rest{$tmp[0]}=join("_",$left_gene,$right_gene);
		}
		
		
		
	}	
	
	
	##output
	open OUT,"> $outdir" or die"$!";
	print OUT "liner_junctions\tgene_name\tcircRNAs\tfusion\n";
	foreach(keys %refliner)
	{
	 my @arr=split/_/,$_;
	 my $left=join("_",$arr[0],$arr[1],$arr[3]);
	 my $right=join("_",$arr[0],$arr[2],$arr[3]);
	 print OUT $_,"\t",$refliner{$_},"\t";
	 print OUT $liner_left{$left}{"circ"},";",$liner_right{$right}{"circ"},"\t";
	 print OUT $liner_left{$left}{"fusion"},";",$liner_right{$right}{"fusion"},"\n";
	 
	}
	## output rest circRNA that no match to liner
	foreach(keys %circ_rest){
	print OUT "NA","\t",$circ_rest{$_},"\t",$_,"\t","NA\n";
	}
	##
	foreach(keys %fus_rest){
		my $tp=$fus_rest{$_};
		my @temp=split/_/,$tp;
		foreach my $c (@temp){
		print OUT "NA","\t",$c,"\t","NA","\t",$_,"\n";
		}
	
	}

















