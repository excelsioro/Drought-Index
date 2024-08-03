rule targets:
    input:
        "data/ghcnd_all.tar.gz",
        "data/ghcnd_all_files.txt",
        "data/ghcnd-inventory.txt",
        "data/ghcnd-stations.txt"
        "data/ghcnd_cat.gz"

rule concatenate_dly_files:
    input:
        script = "code\concatenate_dly.bash"
        tarball = "data/ghcnd_all.tar.gz"
    output:
        "data/ghcnd_cat.gz"
    shell:
        """
        {input.script}
        ""


rule get_all_archive:
    input:
        script = "code/get_ghcnd_data.bash"
    output:
        "data/ghcnd_all.tar.gz"
    params:
        "ghcnd_all.tar.gz"
    shell:
        """
        {input.script} {params}
        """

rule get_all_filenames:
    input:
        script = "code/get_ghcnd_all_files.bash",
        archive = "data/ghcnd_all.tar.gz"
    output:
        "data/ghcnd_all_files.txt"
    shell:
        """
        {input.script} {input.archive} {output}
        """

rule get_inventory:
    input:
        script = "code/get_ghcnd_data.bash",
    output:
        "data/ghcnd-inventory.txt"
    params:
        file = "ghcnd-inventory.txt"
    shell:
        """
        {input.script} {params.file}
        """

rule get_station_data:
    input:
        script = "code/get_ghcnd_data.bash",
    output:
        "data/ghcnd-stations.txt"
    params:
        file = "ghcnd-stations.txt"
    shell:
        """
        {input.script} {params.file}
        """


