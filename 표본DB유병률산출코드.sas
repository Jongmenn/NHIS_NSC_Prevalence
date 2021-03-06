LIBNAME A 'E:\Project2021\표본유병률';
LIBNAME T120 'D:\EUMC\데이터관리\표본코호트_DB(NHIS_NSC)\T120';
LIBNAME JK 'D:\EUMC\데이터관리\표본코호트_DB(NHIS_NSC)\JK';

%MACRO T120_DISEASE1(yr, S_ICD,E_ICD,N);
/*자격 DB에서 필요한 변수만 정리*/
DATA A.JK&YR.; SET JK.Nhid_jk_&YR.;

/*연도별 자격 (merge key) */
PKEY=COMPRESS(STND_Y)||("-")||COMPRESS(PERSON_ID);
/*불필요한 변수 제외 */
DROP IPSN_TYPE_CD CTRB_PT_TYPE_CD DFAB_GRD_CD DFAB_PTN_CD DFAB_REG_YM;

/*성별 구분*/
IF SEX=1 THEN M=1; ELSE M=0;
IF SEX=2 THEN F=1; ELSE F=0; 

/*성별*연령 구분: 남성 */
IF SEX=1 & AGE_GROUP=0 THEN AG00_M=1; ELSE AG00_M=0;
IF SEX=1 & AGE_GROUP=1 THEN AG01_M=1; ELSE AG01_M=0;
IF SEX=1 & AGE_GROUP=2 THEN AG02_M=1; ELSE AG02_M=0;
IF SEX=1 & AGE_GROUP=3 THEN AG03_M=1; ELSE AG03_M=0;
IF SEX=1 & AGE_GROUP=4 THEN AG04_M=1; ELSE AG04_M=0;
IF SEX=1 & AGE_GROUP=5 THEN AG05_M=1; ELSE AG05_M=0;
IF SEX=1 & AGE_GROUP=6 THEN AG06_M=1; ELSE AG06_M=0;
IF SEX=1 & AGE_GROUP=7 THEN AG07_M=1; ELSE AG07_M=0;
IF SEX=1 & AGE_GROUP=8 THEN AG08_M=1; ELSE AG08_M=0;
IF SEX=1 & AGE_GROUP=9 THEN AG09_M=1; ELSE AG09_M=0;
IF SEX=1 & AGE_GROUP=10 THEN AG10_M=1; ELSE AG10_M=0;
IF SEX=1 & AGE_GROUP=11 THEN AG11_M=1; ELSE AG11_M=0;
IF SEX=1 & AGE_GROUP=12 THEN AG12_M=1; ELSE AG12_M=0;
IF SEX=1 & AGE_GROUP=13 THEN AG13_M=1; ELSE AG13_M=0;
IF SEX=1 & AGE_GROUP=14 THEN AG14_M=1; ELSE AG14_M=0;
IF SEX=1 & AGE_GROUP=15 THEN AG15_M=1; ELSE AG15_M=0;
IF SEX=1 & AGE_GROUP=16 THEN AG16_M=1; ELSE AG16_M=0;
IF SEX=1 & AGE_GROUP=17 THEN AG17_M=1; ELSE AG17_M=0;
IF SEX=1 & AGE_GROUP=18 THEN AG18_M=1; ELSE AG18_M=0;

/*성별*연령 구분: 여성 */
IF SEX=2 & AGE_GROUP=0 THEN AG00_F=1; ELSE AG00_F=0;
IF SEX=2 & AGE_GROUP=1 THEN AG01_F=1; ELSE AG01_F=0;
IF SEX=2 & AGE_GROUP=2 THEN AG02_F=1; ELSE AG02_F=0;
IF SEX=2 & AGE_GROUP=3 THEN AG03_F=1; ELSE AG03_F=0;
IF SEX=2 & AGE_GROUP=4 THEN AG04_F=1; ELSE AG04_F=0;
IF SEX=2 & AGE_GROUP=5 THEN AG05_F=1; ELSE AG05_F=0;
IF SEX=2 & AGE_GROUP=6 THEN AG06_F=1; ELSE AG06_F=0;
IF SEX=2 & AGE_GROUP=7 THEN AG07_F=1; ELSE AG07_F=0;
IF SEX=2 & AGE_GROUP=8 THEN AG08_F=1; ELSE AG08_F=0;
IF SEX=2 & AGE_GROUP=9 THEN AG09_F=1; ELSE AG09_F=0;
IF SEX=2 & AGE_GROUP=10 THEN AG10_F=1; ELSE AG10_F=0;
IF SEX=2 & AGE_GROUP=11 THEN AG11_F=1; ELSE AG11_F=0;
IF SEX=2 & AGE_GROUP=12 THEN AG12_F=1; ELSE AG12_F=0;
IF SEX=2 & AGE_GROUP=13 THEN AG13_F=1; ELSE AG13_F=0;
IF SEX=2 & AGE_GROUP=14 THEN AG14_F=1; ELSE AG14_F=0;
IF SEX=2 & AGE_GROUP=15 THEN AG15_F=1; ELSE AG15_F=0;
IF SEX=2 & AGE_GROUP=16 THEN AG16_F=1; ELSE AG16_F=0;
IF SEX=2 & AGE_GROUP=17 THEN AG17_F=1; ELSE AG17_F=0;
IF SEX=2 & AGE_GROUP=18 THEN AG18_F=1; ELSE AG18_F=0;
RUN;

/*T120 자료에서 필요한 변수만 정리 */
DATA A.T120_&YR.; SET T120.Nhid_gy20_t1_&YR.;

FORMAT RECU FST RECU_DATE FST_DATE DATE1 YYMMDD10.;

/*날짜변수 정리 */
YY=SUBSTR(RECU_FR_DT,1,4);
MM=SUBSTR(RECU_FR_DT,5,2);
DD=SUBSTR(RECU_FR_DT,7,2);

/*요양 개시일*/
RECU=MDY(MM,DD,YY);

/*최초 입원일*/
FST=MDY(SUBSTR(FST_IN_PAT_DT,5,2),SUBSTR(FST_IN_PAT_DT,7,2),SUBSTR(FST_IN_PAT_DT,1,4));
IF FST^=" " THEN FST_STATUS=1; ELSE FST_STATUS=0;           /*최초 입원일이 있는 경우 1 아니면 0 */

/*진료 개시일자 계산하기 */
IF RECU=" " THEN RECU_DATE=FST; ELSE RECU_DATE=RECU; /*RECU가 결측이면 FST(최초입원일)로 입력, RECU가 결측이 아니면 RECU로 입력*/
IF FST ^=" " THEN FST_DATE=FST; ELSE FST_DATE=RECU;      /*FST가 결측이 아니면 FST_DATE는 FST로 입력, 결측이면 RECU_DATE로 입력*/

DATE1=MIN(FST_DATE,RECU_DATE); /*진료 개시일자는 최초입원일이랑 요양개시일자 중 빠른 날로 지정*/
DIFF_PLUS=RECU_DATE-DATE1;       /*요양개시일자-최초입원일로 간주되는 날의 차이 */
CNT_DD   =DIFF_PLUS+VSCN;           /*처음 질환이 발생한 시기부터 누적된 요양일 수 */

/*연도별 자격 (merge key) -> 자격자료와 merge하기위한 식별키*/
PKEY=COMPRESS(YY)||("-")||COMPRESS(PERSON_ID);

/*요양개시일+개별환자 -> 한 환자가 같은날 중복되는 경우를 제거하기위한 식별 키*/
DKEY=COMPRESS(RECU_FR_DT)||("-")||COMPRESS(PERSON_ID);

/*의과 입원/외래, 보건소 외래인 경우만 */
IF FORM_CD IN ("02","03","08"); 

IF FORM_CD="08" THEN FORM_CD="03"; /*보건소 외래 ->외래*/

IF FORM_CD="02" THEN H1=1; ELSE H1=0; /*입원이면 H1=1 아니면 0*/
IF FORM_CD="03" THEN H2=1; ELSE H2=0; /*외래이면 H2=1 아니면 0*/

/*유효한 진료일자만 남기기*/
IF "2002" <=YY<="2013" AND "01" <=MM <="12" AND "01" <=DD <= "31";

/*ICD 코드 주상병/부상병만 고려, 대분류 예시 */
IF  &S_ICD. <= SUBSTR(MAIN_SICK,1,&N.)<=&E_ICD. THEN K1=2; ELSE K1=0; /* 주상병 존재하면 K1= 2*/
IF  &S_ICD. <= SUBSTR(SUB_SICK ,1,&N.)<=&E_ICD. THEN K2=1; ELSE K2=0; /* 부상병 존재하면 K2=1*/

/*주, 부상병을 고려한 점수 index*/
ICD_SCORE=K1+K2;
IF ICD_SCORE>0;

/*무효한 입내원 일수 제외 */
IF VSCN=" " THEN DELETE;
IF VSCN=0 THEN VSCN=1; 

KEEP PKEY DKEY PERSON_ID KEY_SEQ YKIHO_ID RECU_FR_DT FORM_CD MAIN_SICK SUB_SICK RECN VSCN FST_IN_PAT_DT MM DD YY ICD_SCORE H1 H2 RECU FST RECU_DATE FST_DATE DATE1 DIFF_PLUS CNT_DD;
RUN;

/*같은 질환 입원환자에 대해 같은 날짜 청구건 정리*/

/*한 환자가 청구 건수가 연달아 발생하면 하나의 발생으로 간주하여 계산*/
/*(1) 청구 건당 날짜가 같으면 가장 긴 입내원일수 기준*/
/*(2) 만약 청구 건당 날짜와 가장 긴 입내원 일수가 같다면 주/부상병을 고려하여 높은 기준으로 남기기*/
/*(3) 만약 청구 건당 날짜와 가장 긴 입내원 일수가 같고 주/부상병을 고려한 기준도 같다면 하나만 남기기*/

/*DATA 정렬*/
PROC SORT DATA=A.T120_&YR.; BY DKEY DESENDING CNT_DD DESENDING ICD_SCORE; RUN;

DATA A.T120_U_&YR.; SET A.T120_&YR.;
BY DKEY; 
IF FIRST.DKEY^=1 THEN DELETE;
DROP ICD_SCORE;  RUN;

PROC SORT DATA=A.T120_U_&YR.; BY PERSON_ID RECU_DATE; RUN;

%MEND;

/*YR:해당연도*/
/*N: 해당 상병코드의 첫번째 자리수부터 N째 자리수 까지, 예를들어 원래 J453으로 입력되어있는데 N이 3이면(세자리 까지) "J45"로 인식*/
/*S_ICD: 조건 하에서 시작 상병 */
/*E_ICD: 조건 하에서 끝 상병 */
%T120_DISEASE1(yr=2002,S_ICD="J45",E_ICD="J46",N=3);
%T120_DISEASE1(yr=2003,S_ICD="J45",E_ICD="J46",N=3);
%T120_DISEASE1(yr=2004,S_ICD="J45",E_ICD="J46",N=3);
%T120_DISEASE1(yr=2005,S_ICD="J45",E_ICD="J46",N=3);
%T120_DISEASE1(yr=2006,S_ICD="J45",E_ICD="J46",N=3);
%T120_DISEASE1(yr=2007,S_ICD="J45",E_ICD="J46",N=3);
%T120_DISEASE1(yr=2008,S_ICD="J45",E_ICD="J46",N=3);
%T120_DISEASE1(yr=2009,S_ICD="J45",E_ICD="J46",N=3);
%T120_DISEASE1(yr=2010,S_ICD="J45",E_ICD="J46",N=3);
%T120_DISEASE1(yr=2011,S_ICD="J45",E_ICD="J46",N=3);
%T120_DISEASE1(yr=2012,S_ICD="J45",E_ICD="J46",N=3);
%T120_DISEASE1(yr=2013,S_ICD="J45",E_ICD="J46",N=3);

/*위에서 정리한 자료에서 한 환자당 입원, 외래 건수 카운트  */
/*대략적인 연도별 n수 검토 목적...-> 아래서 기준 세워서 적용하기 */
PROC SQL; CREATE TABLE A.C_2002 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2002 GROUP BY PERSON_ID ; QUIT;
PROC SQL; CREATE TABLE A.C_2003 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2003 GROUP BY PERSON_ID ; QUIT;
PROC SQL; CREATE TABLE A.C_2004 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2004 GROUP BY PERSON_ID ; QUIT;
PROC SQL; CREATE TABLE A.C_2005 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2005 GROUP BY PERSON_ID ; QUIT;
PROC SQL; CREATE TABLE A.C_2006 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2006 GROUP BY PERSON_ID ; QUIT;
PROC SQL; CREATE TABLE A.C_2007 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2007 GROUP BY PERSON_ID ; QUIT;
PROC SQL; CREATE TABLE A.C_2008 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2008 GROUP BY PERSON_ID ; QUIT;
PROC SQL; CREATE TABLE A.C_2009 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2009 GROUP BY PERSON_ID ; QUIT;
PROC SQL; CREATE TABLE A.C_2010 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2010 GROUP BY PERSON_ID ; QUIT;
PROC SQL; CREATE TABLE A.C_2011 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2011 GROUP BY PERSON_ID ; QUIT;
PROC SQL; CREATE TABLE A.C_2012 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2012 GROUP BY PERSON_ID ; QUIT;
PROC SQL; CREATE TABLE A.C_2013 AS SELECT DISTINCT YY AS YY, PERSON_ID , SUM(H1) AS H1 , SUM(H2) AS H2 FROM A.t120_u_2013 GROUP BY PERSON_ID ; QUIT;

/*연도별 데이터 수 */
%MACRO DATA_LENGTH(DATA,VAR);
DATA ZZ ; SET A.&DATA._2002-A.&DATA._2013; RUN;
PROC MEANS DATA=ZZ; CLASS YY; VAR &VAR.; RUN;
%MEND;
%DATA_LENGTH(T120,PERSON_ID);      /* ICD-10코드 해당 환자 건수 */
%DATA_LENGTH(T120_U,PERSON_ID); /* 한 환자가 같은날 중복되는 경우 제외한 n수 */
%DATA_LENGTH(C,PERSON_ID);         /* 고유한 환자 수 */


/*기준에 따라 정의해보기 */
/*(1) 연간 입원 유병률: 입원 1회 이상*/
/*(2) 연간 외래 유병률: 외래 3회 이상*/
/*(3) 연간 외래+입원 유병률: 일년 중 외래 3회 이상 or 1회 입원 이상 */
/*해당년도에 입원 1회 또는 외래 3회 이상인 경우는 해당 질환이 있다고 볼 거임*/

%MACRO PYEAR(YR);
PROC SORT DATA=A.T120_U_&YR. NODUPKEY OUT=A.ID&YR.; BY PERSON_ID; QUIT;

DATA A.ID&YR.; SET A.ID&YR.; 
KEEP PERSON_ID; RUN;

/*입원인 경우만 추출 */
DATA A.D1; SET A.T120_U_&YR.;
IF FORM_CD IN ("02"); 
KEEP PERSON_ID H1;
RUN;

/*(1) 입원만 있는 자료에서 고유 id만 추출 -> 입원 1회 이상인 경우 */
PROC SORT DATA=A.D1 NODUPKEY ;BY PERSON_ID; RUN;

/*입원 1회 이상인 경우 */
PROC SQL; CREATE TABLE A.D1_&YR. AS SELECT * FROM A.ID&YR. AS A LEFT JOIN A.D1 AS B ON A.PERSON_ID = B.PERSON_ID; QUIT;
DATA A.D1_&YR.; SET A.D1_&YR.; IF H1="." THEN H1=0; RUN;

/*(2) 외래 3회 이상인 경우 */
DATA A.D2; SET A.T120_U_&YR.;
IF FORM_CD IN ("03");   /*외래인 경우*/
KEEP PERSON_ID H2; RUN;

/*외래 한 사람당 몇건의 외래가 있는지 빈도 */
PROC SQL; CREATE TABLE A.D2_&YR. AS SELECT PERSON_ID, SUM(H2) AS H2_cnt FROM A.D2 GROUP BY PERSON_ID; QUIT;


DATA A.D2_&YR.; SET A.D2_&YR.;
IF H2_CNT>=3;  /*외래 3회 이상 자료만 */
H2=1;              /*외래 기준에 해당하면 1*/
DROP H2_CNT; RUN;

/*입원 환자 정리 자료랑 merge */
PROC SQL; CREATE TABLE A.P&YR. AS SELECT * FROM A.D1_&YR. AS A LEFT JOIN A.D2_&YR. AS B ON A.PERSON_ID = B.PERSON_ID ; QUIT;

/*left join이므로 빈 부분 메꿔주기 */
DATA A.P&YR.; SET A.P&YR.;
IF H2="." THEN H2=0; 
IF H1+H2>0 THEN H3=1 ; ELSE H3=0; RUN;

PROC SQL; CREATE TABLE A.P&YR. AS SELECT * FROM A.P&YR. AS A LEFT JOIN A.JK&YR. AS B ON A.PERSON_ID=B.PERSON_ID;QUIT;

DATA A.P&YR.; SET A.P&YR.;
IF SGG^="" ;
/*입원 기준 으로 연령 그룹, 성별 */
IF H1=1 & AGE_GROUP=0   THEN H1_AG00=1; ELSE H1_AG00=0; IF H1=1 & AGE_GROUP=0   & SEX=1 THEN H1_AG00_M=1; ELSE H1_AG00_M=0; IF H1=1 & AGE_GROUP=0   & SEX=2 THEN H1_AG00_F=1; ELSE H1_AG00_F=0;
IF H1=1 & AGE_GROUP=1   THEN H1_AG01=1; ELSE H1_AG01=0; IF H1=1 & AGE_GROUP=1   & SEX=1 THEN H1_AG01_M=1; ELSE H1_AG01_M=0; IF H1=1 & AGE_GROUP=1   & SEX=2 THEN H1_AG01_F=1; ELSE H1_AG01_F=0;
IF H1=1 & AGE_GROUP=2   THEN H1_AG02=1; ELSE H1_AG02=0; IF H1=1 & AGE_GROUP=2   & SEX=1 THEN H1_AG02_M=1; ELSE H1_AG02_M=0; IF H1=1 & AGE_GROUP=2   & SEX=2 THEN H1_AG02_F=1; ELSE H1_AG02_F=0;
IF H1=1 & AGE_GROUP=3   THEN H1_AG03=1; ELSE H1_AG03=0; IF H1=1 & AGE_GROUP=3   & SEX=1 THEN H1_AG03_M=1; ELSE H1_AG03_M=0; IF H1=1 & AGE_GROUP=3   & SEX=2 THEN H1_AG03_F=1; ELSE H1_AG03_F=0;
IF H1=1 & AGE_GROUP=4   THEN H1_AG04=1; ELSE H1_AG04=0; IF H1=1 & AGE_GROUP=4   & SEX=1 THEN H1_AG04_M=1; ELSE H1_AG04_M=0; IF H1=1 & AGE_GROUP=4   & SEX=2 THEN H1_AG04_F=1; ELSE H1_AG04_F=0;
IF H1=1 & AGE_GROUP=5   THEN H1_AG05=1; ELSE H1_AG05=0; IF H1=1 & AGE_GROUP=5   & SEX=1 THEN H1_AG05_M=1; ELSE H1_AG05_M=0; IF H1=1 & AGE_GROUP=5   & SEX=2 THEN H1_AG05_F=1; ELSE H1_AG05_F=0;
IF H1=1 & AGE_GROUP=6   THEN H1_AG06=1; ELSE H1_AG06=0; IF H1=1 & AGE_GROUP=6   & SEX=1 THEN H1_AG06_M=1; ELSE H1_AG06_M=0; IF H1=1 & AGE_GROUP=6   & SEX=2 THEN H1_AG06_F=1; ELSE H1_AG06_F=0;
IF H1=1 & AGE_GROUP=7   THEN H1_AG07=1; ELSE H1_AG07=0; IF H1=1 & AGE_GROUP=7   & SEX=1 THEN H1_AG07_M=1; ELSE H1_AG07_M=0; IF H1=1 & AGE_GROUP=7   & SEX=2 THEN H1_AG07_F=1; ELSE H1_AG07_F=0;
IF H1=1 & AGE_GROUP=8   THEN H1_AG08=1; ELSE H1_AG08=0; IF H1=1 & AGE_GROUP=8   & SEX=1 THEN H1_AG08_M=1; ELSE H1_AG08_M=0; IF H1=1 & AGE_GROUP=8   & SEX=2 THEN H1_AG08_F=1; ELSE H1_AG08_F=0;
IF H1=1 & AGE_GROUP=9   THEN H1_AG09=1; ELSE H1_AG09=0; IF H1=1 & AGE_GROUP=9   & SEX=1 THEN H1_AG09_M=1; ELSE H1_AG09_M=0; IF H1=1 & AGE_GROUP=9   & SEX=2 THEN H1_AG09_F=1; ELSE H1_AG09_F=0;
IF H1=1 & AGE_GROUP=10 THEN H1_AG10=1; ELSE H1_AG10=0; IF H1=1 & AGE_GROUP=10 & SEX=1 THEN H1_AG10_M=1; ELSE H1_AG10_M=0; IF H1=1 & AGE_GROUP=10 & SEX=2 THEN H1_AG10_F=1; ELSE H1_AG10_F=0; 
IF H1=1 & AGE_GROUP=11 THEN H1_AG11=1; ELSE H1_AG11=0; IF H1=1 & AGE_GROUP=11 & SEX=1 THEN H1_AG11_M=1; ELSE H1_AG11_M=0; IF H1=1 & AGE_GROUP=11 & SEX=2 THEN H1_AG11_F=1; ELSE H1_AG11_F=0;
IF H1=1 & AGE_GROUP=12 THEN H1_AG12=1; ELSE H1_AG12=0; IF H1=1 & AGE_GROUP=12 & SEX=1 THEN H1_AG12_M=1; ELSE H1_AG12_M=0; IF H1=1 & AGE_GROUP=12 & SEX=2 THEN H1_AG12_F=1; ELSE H1_AG12_F=0;
IF H1=1 & AGE_GROUP=13 THEN H1_AG13=1; ELSE H1_AG13=0; IF H1=1 & AGE_GROUP=13 & SEX=1 THEN H1_AG13_M=1; ELSE H1_AG13_M=0; IF H1=1 & AGE_GROUP=13 & SEX=2 THEN H1_AG13_F=1; ELSE H1_AG13_F=0;
IF H1=1 & AGE_GROUP=14 THEN H1_AG14=1; ELSE H1_AG14=0; IF H1=1 & AGE_GROUP=14 & SEX=1 THEN H1_AG14_M=1; ELSE H1_AG14_M=0; IF H1=1 & AGE_GROUP=14 & SEX=2 THEN H1_AG14_F=1; ELSE H1_AG14_F=0;
IF H1=1 & AGE_GROUP=15 THEN H1_AG15=1; ELSE H1_AG15=0; IF H1=1 & AGE_GROUP=15 & SEX=1 THEN H1_AG15_M=1; ELSE H1_AG15_M=0; IF H1=1 & AGE_GROUP=15 & SEX=2 THEN H1_AG15_F=1; ELSE H1_AG15_F=0;
IF H1=1 & AGE_GROUP=16 THEN H1_AG16=1; ELSE H1_AG16=0; IF H1=1 & AGE_GROUP=16 & SEX=1 THEN H1_AG16_M=1; ELSE H1_AG16_M=0; IF H1=1 & AGE_GROUP=16 & SEX=2 THEN H1_AG16_F=1; ELSE H1_AG16_F=0;
IF H1=1 & AGE_GROUP=17 THEN H1_AG17=1; ELSE H1_AG17=0; IF H1=1 & AGE_GROUP=17 & SEX=1 THEN H1_AG17_M=1; ELSE H1_AG17_M=0; IF H1=1 & AGE_GROUP=17 & SEX=2 THEN H1_AG17_F=1; ELSE H1_AG17_F=0;
IF H1=1 & AGE_GROUP=18 THEN H1_AG18=1; ELSE H1_AG18=0; IF H1=1 & AGE_GROUP=18 & SEX=1 THEN H1_AG18_M=1; ELSE H1_AG18_M=0; IF H1=1 & AGE_GROUP=18 & SEX=2 THEN H1_AG18_F=1; ELSE H1_AG18_F=0;

/*외래  기준 으로 연령 그룹, 성별 */
IF H2=1 & AGE_GROUP=0   THEN H2_AG00=1; ELSE H2_AG00=0; IF H2=1 & AGE_GROUP=0   & SEX=1 THEN H2_AG00_M=1; ELSE H2_AG00_M=0; IF H2=1 & AGE_GROUP=0   & SEX=2 THEN H2_AG00_F=1; ELSE H2_AG00_F=0;
IF H2=1 & AGE_GROUP=1   THEN H2_AG01=1; ELSE H2_AG01=0; IF H2=1 & AGE_GROUP=1   & SEX=1 THEN H2_AG01_M=1; ELSE H2_AG01_M=0; IF H2=1 & AGE_GROUP=1   & SEX=2 THEN H2_AG01_F=1; ELSE H2_AG01_F=0;
IF H2=1 & AGE_GROUP=2   THEN H2_AG02=1; ELSE H2_AG02=0; IF H2=1 & AGE_GROUP=2   & SEX=1 THEN H2_AG02_M=1; ELSE H2_AG02_M=0; IF H2=1 & AGE_GROUP=2   & SEX=2 THEN H2_AG02_F=1; ELSE H2_AG02_F=0;
IF H2=1 & AGE_GROUP=3   THEN H2_AG03=1; ELSE H2_AG03=0; IF H2=1 & AGE_GROUP=3   & SEX=1 THEN H2_AG03_M=1; ELSE H2_AG03_M=0; IF H2=1 & AGE_GROUP=3   & SEX=2 THEN H2_AG03_F=1; ELSE H2_AG03_F=0;
IF H2=1 & AGE_GROUP=4   THEN H2_AG04=1; ELSE H2_AG04=0; IF H2=1 & AGE_GROUP=4   & SEX=1 THEN H2_AG04_M=1; ELSE H2_AG04_M=0; IF H2=1 & AGE_GROUP=4   & SEX=2 THEN H2_AG04_F=1; ELSE H2_AG04_F=0;
IF H2=1 & AGE_GROUP=5   THEN H2_AG05=1; ELSE H2_AG05=0; IF H2=1 & AGE_GROUP=5   & SEX=1 THEN H2_AG05_M=1; ELSE H2_AG05_M=0; IF H2=1 & AGE_GROUP=5   & SEX=2 THEN H2_AG05_F=1; ELSE H2_AG05_F=0;
IF H2=1 & AGE_GROUP=6   THEN H2_AG06=1; ELSE H2_AG06=0; IF H2=1 & AGE_GROUP=6   & SEX=1 THEN H2_AG06_M=1; ELSE H2_AG06_M=0; IF H2=1 & AGE_GROUP=6   & SEX=2 THEN H2_AG06_F=1; ELSE H2_AG06_F=0;
IF H2=1 & AGE_GROUP=7   THEN H2_AG07=1; ELSE H2_AG07=0; IF H2=1 & AGE_GROUP=7   & SEX=1 THEN H2_AG07_M=1; ELSE H2_AG07_M=0; IF H2=1 & AGE_GROUP=7   & SEX=2 THEN H2_AG07_F=1; ELSE H2_AG07_F=0;
IF H2=1 & AGE_GROUP=8   THEN H2_AG08=1; ELSE H2_AG08=0; IF H2=1 & AGE_GROUP=8   & SEX=1 THEN H2_AG08_M=1; ELSE H2_AG08_M=0; IF H2=1 & AGE_GROUP=8   & SEX=2 THEN H2_AG08_F=1; ELSE H2_AG08_F=0;
IF H2=1 & AGE_GROUP=9   THEN H2_AG09=1; ELSE H2_AG09=0; IF H2=1 & AGE_GROUP=9   & SEX=1 THEN H2_AG09_M=1; ELSE H2_AG09_M=0; IF H2=1 & AGE_GROUP=9   & SEX=2 THEN H2_AG09_F=1; ELSE H2_AG09_F=0;
IF H2=1 & AGE_GROUP=10 THEN H2_AG10=1; ELSE H2_AG10=0; IF H2=1 & AGE_GROUP=10 & SEX=1 THEN H2_AG10_M=1; ELSE H2_AG10_M=0; IF H2=1 & AGE_GROUP=10 & SEX=2 THEN H2_AG10_F=1; ELSE H2_AG10_F=0; 
IF H2=1 & AGE_GROUP=11 THEN H2_AG11=1; ELSE H2_AG11=0; IF H2=1 & AGE_GROUP=11 & SEX=1 THEN H2_AG11_M=1; ELSE H2_AG11_M=0; IF H2=1 & AGE_GROUP=11 & SEX=2 THEN H2_AG11_F=1; ELSE H2_AG11_F=0;
IF H2=1 & AGE_GROUP=12 THEN H2_AG12=1; ELSE H2_AG12=0; IF H2=1 & AGE_GROUP=12 & SEX=1 THEN H2_AG12_M=1; ELSE H2_AG12_M=0; IF H2=1 & AGE_GROUP=12 & SEX=2 THEN H2_AG12_F=1; ELSE H2_AG12_F=0;
IF H2=1 & AGE_GROUP=13 THEN H2_AG13=1; ELSE H2_AG13=0; IF H2=1 & AGE_GROUP=13 & SEX=1 THEN H2_AG13_M=1; ELSE H2_AG13_M=0; IF H2=1 & AGE_GROUP=13 & SEX=2 THEN H2_AG13_F=1; ELSE H2_AG13_F=0;
IF H2=1 & AGE_GROUP=14 THEN H2_AG14=1; ELSE H2_AG14=0; IF H2=1 & AGE_GROUP=14 & SEX=1 THEN H2_AG14_M=1; ELSE H2_AG14_M=0; IF H2=1 & AGE_GROUP=14 & SEX=2 THEN H2_AG14_F=1; ELSE H2_AG14_F=0;
IF H2=1 & AGE_GROUP=15 THEN H2_AG15=1; ELSE H2_AG15=0; IF H2=1 & AGE_GROUP=15 & SEX=1 THEN H2_AG15_M=1; ELSE H2_AG15_M=0; IF H2=1 & AGE_GROUP=15 & SEX=2 THEN H2_AG15_F=1; ELSE H2_AG15_F=0;
IF H2=1 & AGE_GROUP=16 THEN H2_AG16=1; ELSE H2_AG16=0; IF H2=1 & AGE_GROUP=16 & SEX=1 THEN H2_AG16_M=1; ELSE H2_AG16_M=0; IF H2=1 & AGE_GROUP=16 & SEX=2 THEN H2_AG16_F=1; ELSE H2_AG16_F=0;
IF H2=1 & AGE_GROUP=17 THEN H2_AG17=1; ELSE H2_AG17=0; IF H2=1 & AGE_GROUP=17 & SEX=1 THEN H2_AG17_M=1; ELSE H2_AG17_M=0; IF H2=1 & AGE_GROUP=17 & SEX=2 THEN H2_AG17_F=1; ELSE H2_AG17_F=0;
IF H2=1 & AGE_GROUP=18 THEN H2_AG18=1; ELSE H2_AG18=0; IF H2=1 & AGE_GROUP=18 & SEX=1 THEN H2_AG18_M=1; ELSE H2_AG18_M=0; IF H2=1 & AGE_GROUP=18 & SEX=2 THEN H2_AG18_F=1; ELSE H2_AG18_F=0;

/*입원+외래  기준 으로 연령 그룹, 성별 */
IF H3=1 & AGE_GROUP=0   THEN H3_AG00=1; ELSE H3_AG00=0; IF H3=1 & AGE_GROUP=0   & SEX=1 THEN H3_AG00_M=1; ELSE H3_AG00_M=0; IF H3=1 & AGE_GROUP=0   & SEX=2 THEN H3_AG00_F=1; ELSE H3_AG00_F=0;
IF H3=1 & AGE_GROUP=1   THEN H3_AG01=1; ELSE H3_AG01=0; IF H3=1 & AGE_GROUP=1   & SEX=1 THEN H3_AG01_M=1; ELSE H3_AG01_M=0; IF H3=1 & AGE_GROUP=1   & SEX=2 THEN H3_AG01_F=1; ELSE H3_AG01_F=0;
IF H3=1 & AGE_GROUP=2   THEN H3_AG02=1; ELSE H3_AG02=0; IF H3=1 & AGE_GROUP=2   & SEX=1 THEN H3_AG02_M=1; ELSE H3_AG02_M=0; IF H3=1 & AGE_GROUP=2   & SEX=2 THEN H3_AG02_F=1; ELSE H3_AG02_F=0;
IF H3=1 & AGE_GROUP=3   THEN H3_AG03=1; ELSE H3_AG03=0; IF H3=1 & AGE_GROUP=3   & SEX=1 THEN H3_AG03_M=1; ELSE H3_AG03_M=0; IF H3=1 & AGE_GROUP=3   & SEX=2 THEN H3_AG03_F=1; ELSE H3_AG03_F=0;
IF H3=1 & AGE_GROUP=4   THEN H3_AG04=1; ELSE H3_AG04=0; IF H3=1 & AGE_GROUP=4   & SEX=1 THEN H3_AG04_M=1; ELSE H3_AG04_M=0; IF H3=1 & AGE_GROUP=4   & SEX=2 THEN H3_AG04_F=1; ELSE H3_AG04_F=0;
IF H3=1 & AGE_GROUP=5   THEN H3_AG05=1; ELSE H3_AG05=0; IF H3=1 & AGE_GROUP=5   & SEX=1 THEN H3_AG05_M=1; ELSE H3_AG05_M=0; IF H3=1 & AGE_GROUP=5   & SEX=2 THEN H3_AG05_F=1; ELSE H3_AG05_F=0;
IF H3=1 & AGE_GROUP=6   THEN H3_AG06=1; ELSE H3_AG06=0; IF H3=1 & AGE_GROUP=6   & SEX=1 THEN H3_AG06_M=1; ELSE H3_AG06_M=0; IF H3=1 & AGE_GROUP=6   & SEX=2 THEN H3_AG06_F=1; ELSE H3_AG06_F=0;
IF H3=1 & AGE_GROUP=7   THEN H3_AG07=1; ELSE H3_AG07=0; IF H3=1 & AGE_GROUP=7   & SEX=1 THEN H3_AG07_M=1; ELSE H3_AG07_M=0; IF H3=1 & AGE_GROUP=7   & SEX=2 THEN H3_AG07_F=1; ELSE H3_AG07_F=0;
IF H3=1 & AGE_GROUP=8   THEN H3_AG08=1; ELSE H3_AG08=0; IF H3=1 & AGE_GROUP=8   & SEX=1 THEN H3_AG08_M=1; ELSE H3_AG08_M=0; IF H3=1 & AGE_GROUP=8   & SEX=2 THEN H3_AG08_F=1; ELSE H3_AG08_F=0;
IF H3=1 & AGE_GROUP=9   THEN H3_AG09=1; ELSE H3_AG09=0; IF H3=1 & AGE_GROUP=9   & SEX=1 THEN H3_AG09_M=1; ELSE H3_AG09_M=0; IF H3=1 & AGE_GROUP=9   & SEX=2 THEN H3_AG09_F=1; ELSE H3_AG09_F=0;
IF H3=1 & AGE_GROUP=10 THEN H3_AG10=1; ELSE H3_AG10=0; IF H3=1 & AGE_GROUP=10 & SEX=1 THEN H3_AG10_M=1; ELSE H3_AG10_M=0; IF H3=1 & AGE_GROUP=10 & SEX=2 THEN H3_AG10_F=1; ELSE H3_AG10_F=0; 
IF H3=1 & AGE_GROUP=11 THEN H3_AG11=1; ELSE H3_AG11=0; IF H3=1 & AGE_GROUP=11 & SEX=1 THEN H3_AG11_M=1; ELSE H3_AG11_M=0; IF H3=1 & AGE_GROUP=11 & SEX=2 THEN H3_AG11_F=1; ELSE H3_AG11_F=0;
IF H3=1 & AGE_GROUP=12 THEN H3_AG12=1; ELSE H3_AG12=0; IF H3=1 & AGE_GROUP=12 & SEX=1 THEN H3_AG12_M=1; ELSE H3_AG12_M=0; IF H3=1 & AGE_GROUP=12 & SEX=2 THEN H3_AG12_F=1; ELSE H3_AG12_F=0;
IF H3=1 & AGE_GROUP=13 THEN H3_AG13=1; ELSE H3_AG13=0; IF H3=1 & AGE_GROUP=13 & SEX=1 THEN H3_AG13_M=1; ELSE H3_AG13_M=0; IF H3=1 & AGE_GROUP=13 & SEX=2 THEN H3_AG13_F=1; ELSE H3_AG13_F=0;
IF H3=1 & AGE_GROUP=14 THEN H3_AG14=1; ELSE H3_AG14=0; IF H3=1 & AGE_GROUP=14 & SEX=1 THEN H3_AG14_M=1; ELSE H3_AG14_M=0; IF H3=1 & AGE_GROUP=14 & SEX=2 THEN H3_AG14_F=1; ELSE H3_AG14_F=0;
IF H3=1 & AGE_GROUP=15 THEN H3_AG15=1; ELSE H3_AG15=0; IF H3=1 & AGE_GROUP=15 & SEX=1 THEN H3_AG15_M=1; ELSE H3_AG15_M=0; IF H3=1 & AGE_GROUP=15 & SEX=2 THEN H3_AG15_F=1; ELSE H3_AG15_F=0;
IF H3=1 & AGE_GROUP=16 THEN H3_AG16=1; ELSE H3_AG16=0; IF H3=1 & AGE_GROUP=16 & SEX=1 THEN H3_AG16_M=1; ELSE H3_AG16_M=0; IF H3=1 & AGE_GROUP=16 & SEX=2 THEN H3_AG16_F=1; ELSE H3_AG16_F=0;
IF H3=1 & AGE_GROUP=17 THEN H3_AG17=1; ELSE H3_AG17=0; IF H3=1 & AGE_GROUP=17 & SEX=1 THEN H3_AG17_M=1; ELSE H3_AG17_M=0; IF H3=1 & AGE_GROUP=17 & SEX=2 THEN H3_AG17_F=1; ELSE H3_AG17_F=0;
IF H3=1 & AGE_GROUP=18 THEN H3_AG18=1; ELSE H3_AG18=0; IF H3=1 & AGE_GROUP=18 & SEX=1 THEN H3_AG18_M=1; ELSE H3_AG18_M=0; IF H3=1 & AGE_GROUP=18 & SEX=2 THEN H3_AG18_F=1; ELSE H3_AG18_F=0;
RUN;


PROC SQL; CREATE TABLE A.P_SGG&YR. AS SELECT 
/*시군구 기준, 전체 */
SGG,  SUM(H1) AS H1, SUM(H2) AS H2, SUM(H3) AS H3 , 

/*입원 기준 연령별  */
SUM(H1_AG00) AS H1_AG00, SUM(H1_AG01) AS H1_AG01, SUM(H1_AG02) AS H1_AG02, SUM(H1_AG03) AS H1_AG03, SUM(H1_AG04) AS H1_AG04, 
SUM(H1_AG05) AS H1_AG05, SUM(H1_AG06) AS H1_AG06, SUM(H1_AG07) AS H1_AG07, SUM(H1_AG08) AS H1_AG08, SUM(H1_AG09) AS H1_AG09, 
SUM(H1_AG10) AS H1_AG10, SUM(H1_AG11) AS H1_AG11, SUM(H1_AG12) AS H1_AG12, SUM(H1_AG13) AS H1_AG13, SUM(H1_AG14) AS H1_AG14, 
SUM(H1_AG15) AS H1_AG15, SUM(H1_AG16) AS H1_AG16, SUM(H1_AG17) AS H1_AG17, SUM(H1_AG18) AS H1_AG18,

/*입원 기준 연령별 남성  */
SUM(H1_AG00_M) AS H1_M_AG00, SUM(H1_AG01_M) AS H1_M_AG01, SUM(H1_AG02_M) AS H1_M_AG02, SUM(H1_AG03_M) AS H1_M_AG03,
SUM(H1_AG04_M) AS H1_M_AG04, SUM(H1_AG05_M) AS H1_M_AG05, SUM(H1_AG06_M) AS H1_M_AG06, SUM(H1_AG07_M) AS H1_M_AG07,
SUM(H1_AG08_M) AS H1_M_AG08, SUM(H1_AG09_M) AS H1_M_AG09, SUM(H1_AG10_M) AS H1_M_AG10, SUM(H1_AG11_M) AS H1_M_AG11,
SUM(H1_AG12_M) AS H1_M_AG12, SUM(H1_AG13_M) AS H1_M_AG13, SUM(H1_AG14_M) AS H1_M_AG14, SUM(H1_AG15_M) AS H1_M_AG15,
SUM(H1_AG16_M) AS H1_M_AG16, SUM(H1_AG17_M) AS H1_M_AG17, SUM(H1_AG18_M) AS H1_M_AG18,

/*입원 기준 연령별 여성  */
SUM(H1_AG00_F) AS H1_F_AG00, SUM(H1_AG01_F) AS H1_F_AG01, SUM(H1_AG02_F) AS H1_F_AG02, SUM(H1_AG03_F) AS H1_F_AG03,
SUM(H1_AG04_F) AS H1_F_AG04, SUM(H1_AG05_F) AS H1_F_AG05, SUM(H1_AG06_F) AS H1_F_AG06, SUM(H1_AG07_F) AS H1_F_AG07,
SUM(H1_AG08_F) AS H1_F_AG08, SUM(H1_AG09_F) AS H1_F_AG09, SUM(H1_AG10_F) AS H1_F_AG10, SUM(H1_AG11_F) AS H1_F_AG11,
SUM(H1_AG12_F) AS H1_F_AG12, SUM(H1_AG13_F) AS H1_F_AG13, SUM(H1_AG14_F) AS H1_F_AG14, SUM(H1_AG15_F) AS H1_F_AG15,
SUM(H1_AG16_F) AS H1_F_AG16, SUM(H1_AG17_F) AS H1_F_AG17, SUM(H1_AG18_F) AS H1_F_AG18,

/*외래 기준 연령별  */
SUM(H2_AG00) AS H2_AG00, SUM(H2_AG01) AS H2_AG01, SUM(H2_AG02) AS H2_AG02, SUM(H2_AG03) AS H2_AG03, SUM(H2_AG04) AS H2_AG04, 
SUM(H2_AG05) AS H2_AG05, SUM(H2_AG06) AS H2_AG06, SUM(H2_AG07) AS H2_AG07, SUM(H2_AG08) AS H2_AG08, SUM(H2_AG09) AS H2_AG09, 
SUM(H2_AG10) AS H2_AG10, SUM(H2_AG11) AS H2_AG11, SUM(H2_AG12) AS H2_AG12, SUM(H2_AG13) AS H2_AG13, SUM(H2_AG14) AS H2_AG14, 
SUM(H2_AG15) AS H2_AG15, SUM(H2_AG16) AS H2_AG16, SUM(H2_AG17) AS H2_AG17, SUM(H2_AG18) AS H2_AG18,

/*외래기준 연령별 남성  */
SUM(H2_AG00_M) AS H2_M_AG00_M, SUM(H2_AG01_M) AS H2_M_AG01, SUM(H2_AG02_M) AS H2_M_AG02, SUM(H2_AG03_M) AS H2_M_AG03,
SUM(H2_AG04_M) AS H2_M_AG04_M, SUM(H2_AG05_M) AS H2_M_AG05, SUM(H2_AG06_M) AS H2_M_AG06, SUM(H2_AG07_M) AS H2_M_AG07,
SUM(H2_AG08_M) AS H2_M_AG08_M, SUM(H2_AG09_M) AS H2_M_AG09, SUM(H2_AG10_M) AS H2_M_AG10, SUM(H2_AG11_M) AS H2_M_AG11,
SUM(H2_AG12_M) AS H2_M_AG12_M, SUM(H2_AG13_M) AS H2_M_AG13, SUM(H2_AG14_M) AS H2_M_AG14, SUM(H2_AG15_M) AS H2_M_AG15,
SUM(H2_AG16_M) AS H2_M_AG16_M, SUM(H2_AG17_M) AS H2_M_AG17, SUM(H2_AG18_M) AS H2_M_AG18,

/*외래 기준 연령별 여성  */
SUM(H2_AG00_F) AS H2_F_AG00, SUM(H2_AG01_F) AS H2_F_AG01, SUM(H2_AG02_F) AS H2_F_AG02, SUM(H2_AG03_F) AS H2_F_AG03,
SUM(H2_AG04_F) AS H2_F_AG04, SUM(H2_AG05_F) AS H2_F_AG05, SUM(H2_AG06_F) AS H2_F_AG06, SUM(H2_AG07_F) AS H2_F_AG07,
SUM(H2_AG08_F) AS H2_F_AG08, SUM(H2_AG09_F) AS H2_F_AG09, SUM(H2_AG10_F) AS H2_F_AG10, SUM(H2_AG11_F) AS H2_F_AG11,
SUM(H2_AG12_F) AS H2_F_AG12, SUM(H2_AG13_F) AS H2_F_AG13, SUM(H2_AG14_F) AS H2_F_AG14, SUM(H2_AG15_F) AS H2_F_AG15,
SUM(H2_AG16_F) AS H2_F_AG16, SUM(H2_AG17_F) AS H2_F_AG17, SUM(H2_AG18_F) AS H2_F_AG18,

/*입원+외래 기준 연령별 */
SUM(H3_AG00) AS H3_AG00, SUM(H3_AG01) AS H3_AG01, SUM(H3_AG02) AS H3_AG02, SUM(H3_AG03) AS H3_AG03, SUM(H3_AG04) AS H3_AG04, 
SUM(H3_AG05) AS H3_AG05, SUM(H3_AG06) AS H3_AG06, SUM(H3_AG07) AS H3_AG07, SUM(H3_AG08) AS H3_AG08, SUM(H3_AG09) AS H3_AG09, 
SUM(H3_AG10) AS H3_AG10, SUM(H3_AG11) AS H3_AG11, SUM(H3_AG12) AS H3_AG12, SUM(H3_AG13) AS H3_AG13, SUM(H3_AG14) AS H3_AG14, 
SUM(H3_AG15) AS H3_AG15, SUM(H3_AG16) AS H3_AG16, SUM(H3_AG17) AS H3_AG17, SUM(H3_AG18) AS H3_AG18,

/*입원+외래 기준 연령별 남성 */
SUM(H3_AG00_M) AS H3_M_AG00, SUM(H3_AG01_M) AS H3_M_AG01, SUM(H3_AG02_M) AS H3_M_AG02, SUM(H3_AG03_M) AS H3_M_AG03,
SUM(H3_AG04_M) AS H3_M_AG04, SUM(H3_AG05_M) AS H3_M_AG05, SUM(H3_AG06_M) AS H3_M_AG06, SUM(H3_AG07_M) AS H3_M_AG07,
SUM(H3_AG08_M) AS H3_M_AG08, SUM(H3_AG09_M) AS H3_M_AG09, SUM(H3_AG10_M) AS H3_M_AG10, SUM(H3_AG11_M) AS H3_M_AG11,
SUM(H3_AG12_M) AS H3_M_AG12, SUM(H3_AG13_M) AS H3_M_AG13, SUM(H3_AG14_M) AS H3_M_AG14, SUM(H3_AG15_M) AS H3_M_AG15,
SUM(H3_AG16_M) AS H3_M_AG16, SUM(H3_AG17_M) AS H3_M_AG17, SUM(H3_AG18_M) AS H3_M_AG18,

/*입원+외래 기준 연령별 여성 */
SUM(H3_AG00_F) AS H3_F_AG00, SUM(H3_AG01_F) AS H3_F_AG01, SUM(H3_AG02_F) AS H3_F_AG02, SUM(H3_AG03_F) AS H3_F_AG03,
SUM(H3_AG04_F) AS H3_F_AG04, SUM(H3_AG05_F) AS H3_F_AG05, SUM(H3_AG06_F) AS H3_F_AG06, SUM(H3_AG07_F) AS H3_F_AG07,
SUM(H3_AG08_F) AS H3_F_AG08, SUM(H3_AG09_F) AS H3_F_AG09, SUM(H3_AG10_F) AS H3_F_AG10, SUM(H3_AG11_F) AS H3_F_AG11,
SUM(H3_AG12_F) AS H3_F_AG12, SUM(H3_AG13_F) AS H3_F_AG13, SUM(H3_AG14_F) AS H3_F_AG14, SUM(H3_AG15_F) AS H3_F_AG15,
SUM(H3_AG16_F) AS H3_F_AG16, SUM(H3_AG17_F) AS H3_F_AG17, SUM(H3_AG18_F) AS H3_F_AG18 

FROM A.P&YR. GROUP BY SGG; QUIT;

DATA A.P_SGG&YR.; SET A.P_SGG&YR.;
SIDO=SUBSTR(SGG,1,2);
YEAR=&YR.;
RUN;
%MEND;

/*YR=해당연도 */
%PYEAR(2002);
%PYEAR(2003);
%PYEAR(2004);
%PYEAR(2005);
%PYEAR(2006);
%PYEAR(2007);
%PYEAR(2008);
%PYEAR(2009);
%PYEAR(2010);
%PYEAR(2011);
%PYEAR(2012);
%PYEAR(2013);

/*전체 기준별 유병건수 (1)입원 1회 (2) 외래 3회 이상 (3) 입원 또는 외래*/
DATA A.P_TOT; SET A.P2002-A.P2013;  RUN;
PROC SQL; CREATE TABLE A.P_TOT_CNT AS SELECT  STND_Y, SUM(H1) AS H1_C , SUM(H2) AS H2_C, SUM(H3) AS H3_C FROM A.P_TOT GROUP BY STND_Y; QUIT;


/*해당 기간의 표본 인구수 , 표본 db자격, 전체, 성별, 연령별 */
%MACRO POPYR(YR);
PROC SQL; CREATE TABLE A.POP&YR. AS SELECT SGG , COUNT(SGG) AS TOT, SUM(M) AS M, SUM(F) AS F, 
SUM(AG00_M) AS M_AG00, SUM(AG01_M) AS M_AG01, SUM(AG02_M) AS M_AG02, SUM(AG03_M) AS M_AG03,
SUM(AG04_M) AS M_AG04, SUM(AG05_M) AS M_AG05, SUM(AG06_M) AS M_AG06, SUM(AG07_M) AS M_AG07,
SUM(AG08_M) AS M_AG08, SUM(AG09_M) AS M_AG09, SUM(AG10_M) AS M_AG10, SUM(AG11_M) AS M_AG11,
SUM(AG12_M) AS M_AG12, SUM(AG13_M) AS M_AG13, SUM(AG14_M) AS M_AG14, SUM(AG15_M) AS M_AG15,
SUM(AG16_M) AS M_AG16, SUM(AG17_M) AS M_AG17, SUM(AG18_M) AS M_AG18,
SUM(AG00_F) AS F_AG00,  SUM(AG01_F) AS F_AG01,  SUM(AG02_F) AS F_AG02,  SUM(AG03_F) AS F_AG03,
SUM(AG04_F) AS F_AG04,  SUM(AG05_F) AS F_AG05,  SUM(AG06_F) AS F_AG06,  SUM(AG07_F) AS F_AG07,
SUM(AG08_F) AS F_AG08,  SUM(AG09_F) AS F_AG09,  SUM(AG10_F) AS F_AG10,  SUM(AG11_F) AS F_AG11,
SUM(AG12_F) AS F_AG12,  SUM(AG13_F) AS F_AG13,  SUM(AG14_F) AS F_AG14,  SUM(AG15_F) AS F_AG15,
SUM(AG16_F) AS F_AG16,  SUM(AG17_F) AS F_AG17,  SUM(AG18_F) AS F_AG18   FROM A.JK&YR. GROUP BY SGG; QUIT;
%MEND;

%POPYR(2002);
%POPYR(2003);
%POPYR(2004);
%POPYR(2005);
%POPYR(2006);
%POPYR(2007);
%POPYR(2008);
%POPYR(2009);
%POPYR(2010);
%POPYR(2011);
%POPYR(2012);
%POPYR(2013);

/*전치 시켜서 연도별 붙이기 */
%MACRO PYEAR_T(YR);

/*자격  전치 */
DATA Z1; SET A.POP&YR.; KEEP SGG M_AG00-M_AG18 ;RUN;
DATA Z2; SET A.POP&YR.; KEEP SGG F_AG00-F_AG18  ;RUN;

PROC TRANSPOSE DATA=Z1 OUT=ZZ1; BY SGG; RUN;
PROC TRANSPOSE DATA=Z2 OUT=ZZ2; BY SGG; RUN;

DATA ZZ1; SET ZZ1; POP_M=COL1; DROP COL1; RUN; 
DATA ZZ2; SET ZZ2; POP_F=COL1; KEEP SGG POP_F; RUN;

DATA ZZ; MERGE ZZ1 ZZ2; BY SGG; 
POP=POP_M+POP_F; 
KEY=COMPRESS(SGG)||("-")||COMPRESS(SUBSTR(_NAME_,3,4));
AG=SUBSTR(_NAME_,3,4);
DROP _NAME_; RUN;

/*유병건수 전치 */
DATA Z1; SET A.P_SGG&YR.; KEEP SGG  H3_AG00-H3_AG18 ; RUN;
DATA Z2; SET A.P_SGG&YR.; KEEP SGG  H3_M_AG00-H3_M_AG18 ; RUN;
DATA Z3; SET A.P_SGG&YR.; KEEP SGG  H3_F_AG00-H3_F_AG18 ; RUN;

PROC TRANSPOSE DATA=Z1 OUT=ZZ1; BY SGG ; RUN;
PROC TRANSPOSE DATA=Z2 OUT=ZZ2; BY SGG ; RUN;
PROC TRANSPOSE DATA=Z3 OUT=ZZ3; BY SGG ; RUN;

DATA ZZ1; SET ZZ1; T=COL1; DROP COL1; RUN;
DATA ZZ2; SET ZZ2;  M=COL1; KEEP SGG M; RUN;
DATA ZZ3; SET ZZ3;  F=COL1; KEEP SGG F; RUN;

DATA A.P_SGG_T&YR.; MERGE ZZ1 ZZ2 ZZ3;  BY SGG; 
AG=SUBSTR(_NAME_,4,4);
KEY=COMPRESS(SGG)||("-")||COMPRESS(AG);
DROP _NAME_;
YEAR=&YR.; RUN;

PROC SQL; CREATE TABLE A.P_SGG_T&YR. AS SELECT * FROM A.P_SGG_T&YR. AS A LEFT JOIN ZZ AS B ON A.KEY=B.KEY; QUIT;

DATA A.P_SGG_T&YR; 
RETAIN KEY SGG AG YEAR POP POP_M POP_F T M F ;
SET  A.P_SGG_T&YR; RUN;

%MEND;

%PYEAR_T(2002);
%PYEAR_T(2003);
%PYEAR_T(2004);
%PYEAR_T(2005);
%PYEAR_T(2006);
%PYEAR_T(2007);
%PYEAR_T(2008);
%PYEAR_T(2009);
%PYEAR_T(2010);
%PYEAR_T(2011);
%PYEAR_T(2012);
%PYEAR_T(2013);


