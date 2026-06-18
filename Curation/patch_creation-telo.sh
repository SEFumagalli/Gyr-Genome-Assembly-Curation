#created by Sarah E. Fumagalli

patch_dir="/assembly/verkko2.2.1_hifi-duplex_tporec/8-manualResolution/telomeres"
verkko_dir="/assembly/verkko2.2.1_hifi-duplex_tporec"
verkko_fillet_dir="/assembly/verkko2.2.1_hifi-duplex_tporec_verkko_fillet"

## ------------------------------------------------------------------------------------------------------------------------------------------------

1. Find telomeres not assigned a chromosome

	This list can be found using translation_merged.tsv created by Verkko-Fillet (in-house script).
	Using Bandage can also be a quick way to assess the loose telomeres.

	Only two telomeres need a patch-like fix:
	    
	    - one was named a gap by Verkko-Fillet --> gapid_38
	    - haplotype2-0000346



2. Identify flanking utigs and grab their fasta

    cd verkko2.2.1_hifi-duplex_tporec/8-manualResolution/telomeres
	
	mkdir telo_1854 - directory for gapid_38
	mkdir telo_2468 - directory for haplotype2-0000346


    Grab the flanking utigs

        - telo_1854:
            	
            - telo
        	
                grep utig4-1854 ../../5-untip/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > telo_1854/utig4-1854.fasta
        	
            - chromosome
            	
                grep utig4-2375 ../../5-untip/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > telo_2468/utig4-2375.fasta
        
        - telo_2468:
        	
            - telo
        	
                grep utig4-1550 ../../5-untip/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > telo_1854/utig4-1550.fasta
        	
            - chromosome
        	
                grep utig4-2468 ../../5-untip/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa | awk '/^S/{print ">"$2;print $3}' > telo_2468/utig4-2468.fasta
        	   
        	        	
            - grab the full telomere as well in this case (consists of multiple utigs and gap)
            
                grep -A1 haplotype2-0000346 assembly.fasta



3. Align utigs with minimap2 to find overlap

    Choose best alignment

    	- telo_1854:
	
            minimap2 -x asm5 -t 48 utig4-2375.fasta utig4-1854.fasta > utig4-2375_utig4-1854.paf 2> utig4-2375_utig4-1854.err

    	- telo_2468:
	
            - telo to chromosome
        
            	minimap2 -x asm5 -t 48 utig4-2468.fasta utig4-1550.fasta > utig4-2468_utig4-1550.paf 2> utig4-2468_utig4-1550.err
            	
            - whole telo to chromosome
        
                minimap2 -x asm5 -t 48 hap2_346.fasta utig4-2468.fasta > utig4-2468_hap2_346.paf 2> utig4-2468_hap2_346.err



4. Cut overlapping segment

    Extract segment bewtween telomere and chromosome using locations from minimap2 output

    	- telo_1854:
	
        	samtools faidx utig4-1854.fasta utig4-1854:1889445-2768585 > utig4-1854_line2.fasta

        - telo_2468:
        
            samtools faidx hap2_346.fasta.hpc haplotype2-0000346:2855680-7501567 > hap2_346_line1.fasta



5. Realign to segment

    Align both the telomere and chromosome to the segment
    
    This will give us the pair of alignments needed for Verkko

    	- telo_1854:
            
            - telo to segment
            	
            	minimap2 -x asm5 -t 48 utig4-1854_line2.fasta utig4-1854.fasta > utig4-1854_utig4-1854_line2.paf 2> utig4-1854_utig4-1854_line2.err
        	
        	- chromosome to segment
	
            	minimap2 -x asm5 -t 48 utig4-1854_line2.fasta utig4-2375.fasta > utig4-2375_utig4-1854_line2.paf 2> utig4-2375_utig4-1854_line2.err

        - telo_2468:
        
            - telo to segment
            
            	minimap2 -x asm5 -t 48 hap2_346_line1.fasta utig4-2468.fasta > utig4-2468_hap2_346_line1.paf 2> utig4-2468_hap2_346_line1.err
            	
            - chromosome to segment
            
            	minimap2 -x asm5 -t 48 hap2_346_line1.fasta hap2_346.fasta.hpc > hap2_346_hap2_346_line1.paf 2> hap2_346_hap2_346_line1.err

            - all alignment were very poor and inconsistent for both sides of the segment - likely highly repetative 
            

6. Save alignments as patch

    - telo_1854:

        - telo to segment
        
            sed -n '1p' utig4-1854_utig4-1854_line2_sorted.paf > utig4-1854_utig4-1854_line1_patch.paf
            
        - chromosome to segment
        
            sed -n '1p' utig4-2375_utig4-1854_line2_sorted.paf > utig4-2375_utig4-1854_line1_patch.paf



7. Convert paf to gaf

    - telo_1854:

        -  telo to segment
        
            sed s/de:f://g utig4-1854_utig4-1854_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-1854_utig4-1854_line1_patch.gaf 
            
        - chromosome to segment
        
            sed s/de:f://g utig4-2375_utig4-1854_line1_patch.paf | awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > utig4-2375_utig4-1854_line1_patch.gaf

 
8. Final processing of these types of patches can be found in patch_creation-final.sh