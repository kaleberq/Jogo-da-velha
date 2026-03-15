/// Chaves do payload JSON da mensagem requestMove (row, col).
enum RequestMoveDataKeyEnum {
  row('row'),
  col('col');

  final String key;

  const RequestMoveDataKeyEnum(this.key);
}
