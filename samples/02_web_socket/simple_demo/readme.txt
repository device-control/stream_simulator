�g�����F

�^�[�~�i���œ���m�F������@
1: server ���N������i�G�R�[�j
$ ruby websocket_server.rb

2: client �� pry �Ŏ��s����
$ pry -r ./websocket_client.rb
# $c0 �� client �C���X�^���X���ݒ肳���
> $c0.open
> $c0.write "string"
> $c0.write_binary "binary"
> $c0.close


html �œ���m�F������@
1: server ���N������i�G�R�[�j
$ ruby websocket_server.rb

2: web �T�C�g���N��
$ cd ../singlepage_demo
# gulp ���C���X�g�[������Ă��邱��
$ gulp 
�u���E�U�� localhost:8000 �ɃA�N�Z�X�� websocket ����I������
