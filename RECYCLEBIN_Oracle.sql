/***********************************************************************************
*  ���������-���������� �������. �� ��������� ������� ��������. 
***********************************************************************************/

  -- ��������� ������� ��� ������
  ALTER SESSION SET RECYCLEBIN=OFF;
  -- ��������� �������
  ALTER SYSTEM SET RECYCLEBIN=OFF SCOPE=SPFILE;
  -- �������� ������� ��� ������
  ALTER SESSION SET RECYCLEBIN=ON;
  -- �������� �������
  ALTER SYSTEM SET RECYCLEBIN=ON SCOPE=SPFILE;

/***********************************************************************************
*  �������� ��������� (���������� � �������) �������� 
***********************************************************************************/

  -- ������ ��� ������� ������������
  select * from user_recyclebin;
  select * from recyclebin;
  -- ��� ��������� �������
  select * from dba_recyclebin;
  
/***********************************************************************************
*  ��������������� ������ �� ������� 
***********************************************************************************/
  
  -- ����������� ���������� ��������� ������ my_table
  flashback table my_table to before drop;
  -- ����������� ��������� ���������� ������ table1
  flashback table "BIN$CxaooGNESZa4GThzDSX5SQ==$0" to before drop;
  
/***********************************************************************************
*  ������ ������� 
***********************************************************************************/
  -- ������� ��� ������ ������� my_table �� �������
  purge table my_table;
  -- ������� ������� �� ������� �� ���������� �����
  purge table "BIN$0Vq5kNlvTS6G/uyKOlzdAw==$0";
   -- ������� ��� ������� ������������ "MOTOR" �� ����������� TRNDATA.
  purge tablespace TRNDATA user MOTOR;
  -- ������� ��� �������  �� ����������� TRNDATA.
  purge tablespace TRNDATA;
  -- ������� ��� ������� �� ������� �������� ������������
  purge recyclebin;
  -- ������� ��� ������� �� �������, ������� ��������� ��������
  purge dba_recyclebin;  
