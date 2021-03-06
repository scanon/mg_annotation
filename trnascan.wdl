workflow trnascan {

  String imgap_input_fasta
  String imgap_project_id
  Int    additional_threads
  String trnascan_se_bin = "/opt/omics/bin/tRNAscan-SE"
  String pick_and_transform_to_gff_bin =  "/opt/omics/bin/structural_annotation/trna_pick_and_transform_to_gff.py"

  call trnascan_ba {
    input:
      bin = trnascan_se_bin,
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id,
      threads = additional_threads,
  }
  call pick_and_transform_to_gff {
    input:
      bin = pick_and_transform_to_gff_bin,
      project_id = imgap_project_id,
      bacterial_out = trnascan_ba.bacterial_out,
      archaeal_out = trnascan_ba.archaeal_out
  }
  output {
    File gff = pick_and_transform_to_gff.gff
  }
}

task trnascan_ba {

  String bin
  File input_fasta
  String project_id
  Int    threads

  command {
    ${bin} -B --thread ${threads} ${input_fasta} &> ${project_id}_trnascan_bacterial.out
    ${bin} -A --thread ${threads} ${input_fasta} &> ${project_id}_trnascan_archaeal.out
  }

  runtime {
    time: "1:00:00"
    mem: "86G"
  }

  output {
    File bacterial_out = "${project_id}_trnascan_bacterial.out"
    File archaeal_out = "${project_id}_trnascan_archaeal.out"
  }
}

task pick_and_transform_to_gff {

  String bin
  String project_id
  File   bacterial_out
  File   archaeal_out
  
  command {
    ${bin} ${bacterial_out} ${archaeal_out} > ${project_id}_trna.gff
  }

  runtime {
    time: "1:00:00"
    mem: "86G"
  }

  output {
    File gff = "${project_id}_trna.gff"
  }
}
