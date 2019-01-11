import logging
import os
import sys
import shutil

import zmq
from generate import generate_keys, make_clean_dirs


def run():
    base_dir = os.path.dirname(__file__)
    client_dir = os.path.join(base_dir, 'client')
    keys_dir = os.path.join(client_dir, 'certificates')
    server_keys_dir = os.path.join(base_dir, 'server','certificates')
    server_keys_authorized = os.path.join(base_dir, 'server','authorized')

    make_clean_dirs([client_dir])
    generate_keys(client_dir)
    ctx = zmq.Context.instance()
    client = ctx.socket(zmq.REQ)
    authenticator_refresher = ctx.socket(zmq.PUSH)
    authenticator_refresher.connect("tcp://127.0.0.1:9010")
    # shutil.copy(os.path.join(keys_dir,"id.key"),server_keys_authorized)

    if len(sys.argv) == 2:
        if sys.argv[1] == "--copy-id":
            shutil.copy(os.path.join(keys_dir,"id.key"),server_keys_authorized)
            authenticator_refresher.send(b"REFRESH")




    # We need two certificates, one for the client and one for
    # the server. The client must know the server's public key
    # to make a CURVE connection.
    client_secret_file = os.path.join(keys_dir, "id.key_secret")
    client_public, client_secret = zmq.auth.load_certificate(client_secret_file)
    client.curve_secretkey = client_secret
    client.curve_publickey = client_public
    server_public_file = os.path.join(server_keys_dir, "id.key")
    server_public, _ = zmq.auth.load_certificate(server_public_file)
    # The client must know the server's public key to make a CURVE connection.
    client.curve_serverkey = server_public
    client.connect('tcp://127.0.0.1:9000')


    client.send(b"hi")
    print("debug")

    resp = client.recv()
    print(resp)
    if resp == b"hello":
        logging.info("Ironhouse test OK")
    else:
        logging.error("Ironhouse test FAIL")






if __name__ == '__main__':
    if zmq.zmq_version_info() < (4,0):
        raise RuntimeError("Security is not supported in libzmq version < 4.0. libzmq version {0}".format(zmq.zmq_version()))

    if '-v' in sys.argv:
        level = logging.DEBUG
    else:
        level = logging.INFO

    logging.basicConfig(level=level, format="[%(levelname)s] %(message)s")

    run()