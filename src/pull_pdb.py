import sys
import argparse
import json
import multiprocessing as mp
import Bio.PDB as BPDB
import os


def consumer(code, result_queue):
    try:
        result_queue.put(
            (BPDB.PDBList().retrieve_pdb_file(pdb_code=code[0:4]),
             "Pull Successful")
        )
    except:
        result_queue.put(("", "Pull Failed at Download"))


class output_handler(object):
    def __init__(self):
        """Initialize the output handler"""
        self.data = {}
        self.log = []
        pass

    def get_sequence(self, chain):
        return {"residue": str(chain.get_sequence())}.items()

    def get_angles(self, chain):
        return {"angles": {"phi": [x[0] for x in chain.get_phi_psi_list()],
                "psi": [x[1] for x in chain.get_phi_psi_list()],
                "theta": chain.get_theta_list(),
                "tau": chain.get_tau_list()}
                }.items()

    def __call__(self, code, pull_outcome):
        """Implement the output handler logic"""
        filename, outcome = pull_outcome
        if outcome == "Pull Successful":
            structure = BPDB.PDBParser().get_structure(code[0:4], filename)
            os.remove(filename)
            os.rmdir("/".join(filename.split("/")[:-1]))

            try:
                chain = BPDB.PPBuilder().build_peptides(
                    structure[0][code[4].upper()]
                )[0]
            except:
                chain = BPDB.PPBuilder().build_peptides(
                    next(structure[0].get_chains())
                )[0]

            try:
                self.data[code[0:5]] = dict(
                    self.get_sequence(chain)
                    + self.get_angles(chain)
                )
                self.log.append(code + " >>> " + outcome)
            except:
                self.log.append(code + " >>> Pull Failed on a Feature")

        else:
            self.log.append(code + " >>> " + outcome)
        pass


def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("out_dataset", type=str)
    parser.add_argument("out_log", type=str)

    args = parser.parse_args()

    batch = sys.stdin.readlines()

    result_queue = mp.Queue()

    output = output_handler()

    while len(batch) > 0:
        code = batch.pop().strip()
        proc = mp.Process(target=consumer, args=(code, result_queue,))

        proc.start()
        proc.join(30)
        if proc.is_alive():
            result_queue.put(("", "Pull Timed Out"))
            proc.terminate()
            proc.join()

        output(code, result_queue.get())

    json.dump(output.data, open(args.out_dataset, "w"), indent=4)

    with open(args.out_log, "w") as out:
        for item in output.log:
            out.write("{}\n".format(item))

if __name__ == "__main__":
    main()
