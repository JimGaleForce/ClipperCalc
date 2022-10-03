/*
 * Author and owner: Touchstone Business Creations, Jim Gale
 *
 * Calc (c) Touchstone Business Creations, Jim Gale, 1991-2022
 */
// FOR CALC20 and above!  ...1-22-94
// Removed paid license requirement ...10-3-2022
#include "math.h"
#include "extend.h"

double _sin(double ANGLE);
double _cos(double ANGLE);
double _tan(double ANGLE);
double _arcsin(double xSIN);
double dround(double nD, int nDec);
double _arccos(double xCOS);
double _arctan(double xTAN);
double _csc(double nAngle);
double _sec(double nAngle);
double _cot(double nAngle);
double _factorial(int nNum);
double _invlog(double nLog);
double _dtor(double nAngle);
double _rtod(double nArc);
int _sign(double nNo);
double _fabs(double x);
// double _pwr(double x, int n);

CLIPPER SIN()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_sin(_parnd(1)));
  }
  else
    _retni(0);
}

CLIPPER COS()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_cos(_parnd(1)));
  }
  else
    _retni(0);
}

CLIPPER TAN()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_tan(_parnd(1)));
  }
  else
    _retni(0);
}

CLIPPER SINR()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_sin(_rtod(_parnd(1))));
  }
  else
    _retni(0);
}

CLIPPER COSR()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_cos(_rtod(_parnd(1))));
  }
  else
    _retni(0);
}

CLIPPER TANR()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_tan(_rtod(_parnd(1))));
  }
  else
    _retni(0);
}

CLIPPER ASIN()
{

  if (_parinfo(1) == NUMERIC)
  {
    if (_parnd(1) <= 1. && _parnd(1) >= -1.)
    {
      _retnd(_arcsin(_parnd(1)));
    }
    else
      _retni(0);
  }
  else
    _retni(0);
}

CLIPPER ASINR()
{

  if (_parinfo(1) == NUMERIC)
  {
    if (_parnd(1) <= 1. && _parnd(1) >= -1.)
    {
      _retnd(_dtor(_arcsin(_parnd(1))));
    }
    else
      _retni(0);
  }
  else
    _retni(0);
}

CLIPPER ACOS()
{

  if (_parinfo(1) == NUMERIC)
  {
    if (_parnd(1) <= 1. && _parnd(1) >= -1.)
    {
      _retnd(_arccos(_parnd(1)));
    }
    else
      _retni(0);
  }
  else
    _retni(0);
}

CLIPPER ACOSR()
{

  if (_parinfo(1) == NUMERIC)
  {
    if (_parnd(1) <= 1. && _parnd(1) >= -1.)
    {
      _retnd(_dtor(_arccos(_parnd(1))));
    }
    else
      _retni(0);
  }
  else
    _retni(0);
}

CLIPPER ATAN()
{

  if (_parinfo(1) == NUMERIC)
  {
    if (_parnd(1) <= 1. && _parnd(1) >= -1.)
    {
      _retnd(_arctan(_parnd(1)));
    }
    else
      _retni(0);
  }
  else
    _retni(0);
}

CLIPPER ATANR()
{

  if (_parinfo(1) == NUMERIC)
  {
    if (_parnd(1) <= 1. && _parnd(1) >= -1.)
    {
      _retnd(_dtor(_arctan(_parnd(1))));
    }
    else
      _retni(0);
  }
  else
    _retni(0);
}

CLIPPER PI()
{
  _retnd(3.141592653589792);
}

CLIPPER FACTORIAL()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_factorial(_parni(1)));
  }
  else
    _retni(0);
}

CLIPPER INVLOG()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_invlog(_parnd(1)));
  }
  else
    _retni(0);
}

CLIPPER DTOR()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_dtor(_parnd(1)));
  }
  else
    _retni(0);
}

CLIPPER RTOD()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_rtod(_parnd(1)));
  }
  else
    _retni(0);
}

CLIPPER SIGN()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retni(_sign(_parnd(1)));
  }
  else
    _retni(0);
}

CLIPPER CSC()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_csc(_parnd(1)));
  }
  else
    _retni(0);
}

CLIPPER SEC()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_sec(_parnd(1)));
  }
  else
    _retni(0);
}

CLIPPER COT()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_cot(_parnd(1)));
  }
  else
    _retni(0);
}

CLIPPER CSCR()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_csc(_rtod(_parnd(1))));
  }
  else
    _retni(0);
}

CLIPPER SECR()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_sec(_rtod(_parnd(1))));
  }
  else
    _retni(0);
}

CLIPPER COTR()
{

  if (_parinfo(1) == NUMERIC)
  {
    _retnd(_cot(_rtod(_parnd(1))));
  }
  else
    _retni(0);
}

CLIPPER CALCTRIGX()
{
  _retc("Copyright 1993 Touchstone Business Creations\0");
}

double _sin(double ANGLE)
{
  double A;
  A = ((double)((ANGLE >= 270.) ? ANGLE - (double)360. : ((ANGLE >= 90.) ? (double)180. - ANGLE : ANGLE)));
  A = (double)(A * (double)3.14159265358979) / (double)180.;
  return ((double)(A - pow(A, (double)3.) / (double)6. + pow(A, (double)5.) / (double)120. - pow(A, 7.) / 5040. +
                   pow(A, (double)9.) / (double)362880. - pow(A, (double)11.) / (double)39916800. +
                   pow(A, (double)13.) / (double)6227020800. - pow(A, (double)15.) / (double)1307674368000. +
                   pow(A, (double)17.) / (double)355687428096000.));
}
double _sin2(double A)
{
  return ((double)(A - pow(A, (double)3.) / (double)6. + pow(A, (double)5.) / (double)120. - pow(A, 7.) / 5040. +
                   pow(A, (double)9.) / (double)362880. - pow(A, (double)11.) / (double)39916800. +
                   pow(A, (double)13.) / (double)6227020800. - pow(A, (double)15.) / (double)1307674368000. +
                   pow(A, (double)17.) / (double)355687428096000.));
}

double _cos(double ANGLE)
{
  double A;
  A = (double)((ANGLE >= 270.) ? 360. - ANGLE : ((ANGLE >= 90.) ? ANGLE - 180. : ANGLE));
  A = A * (double)3.14159265358979 / 180.;
  return ((double)(ANGLE >= 90. && ANGLE <= 270. ? -1 : 1) * (1. - pow(A, 2.) / 2. + pow(A, 4.) / 24. -
                                                              pow(A, 6.) / 720. + pow(A, 8.) / 40320. - pow(A, 10.) / (double)3628800. +
                                                              pow(A, 12.) / (double)479001600. - pow(A, 14.) / (double)87178291200. +
                                                              pow(A, (double)16.) / (double)20922789888000.));
}
double _cos2(double A)
{
  return (/*(double) (ANGLE>=90. && ANGLE<=270. ? -1:1) **/ (1. - pow(A, 2.) / 2. + pow(A, 4.) / 24. -
                                                             pow(A, 6.) / 720. + pow(A, 8.) / 40320. - pow(A, 10.) / (double)3628800. +
                                                             pow(A, 12.) / (double)479001600. - pow(A, 14.) / (double)87178291200. +
                                                             pow(A, (double)16.) / (double)20922789888000.));
}

double _tan(double ANGLE)
{
  double A, nSIN, nCOS;
  A = (double)(ANGLE >= 270.) ? ANGLE - 360. : ((ANGLE >= 90.) ? ANGLE - 180. : ANGLE);
  A = A * (double)3.14159265358979 / 180;
  nSIN = _sin2(A);
  nCOS = _cos2(A);
  return ((ANGLE == 90. || ANGLE == 270.) ? 0. : (double)nSIN / nCOS);
}

double _arcsin(double xSIN)
{
  double pSIN, tSIN, aSIN;
  pSIN = xSIN;
  xSIN = _fabs(xSIN);
  tSIN = (double)xSIN > .7 ? pow((1. - (pow(-xSIN, 2.))), .5) : xSIN;
  aSIN = (double)(tSIN + pow(tSIN, 3.) / 6. + 3. * pow(tSIN, 5.) / 40. + 15. * pow(tSIN, 7.) / 336. +
                  105. * pow(tSIN, 9.) / 3456. + 945. * pow(tSIN, 11.) / 42240. +
                  10395. * pow(tSIN, 13.) / 599040 + 135135. * pow(tSIN, 15.) / 9676800.) *
         57.29577951308238;
  aSIN = (double)xSIN > .7 ? 90 - dround(aSIN, 2) : dround(aSIN, 2);
  return (pSIN < 0. ? -aSIN : aSIN);
}

double dround(double nD, int nDec)
{
  return ((double)((int)(nD * (pow(10., nDec)) + .5)) / ((int)(pow(10., nDec))));
}

double _arccos(double xCOS)
{
  double pCOS, tCOS, aCOS;
  pCOS = xCOS;
  xCOS = _fabs(xCOS);
  tCOS = (double)xCOS < .7 ? xCOS : pow((1. - pow(xCOS, 2.)), .5);
  aCOS = (double)(tCOS + pow(tCOS, 3.) / 6. + 3. * pow(tCOS, 5.) / 40 + 15. * pow(tCOS, 7.) / 336. +
                  105. * pow(tCOS, 9.) / 3456. + 945. * pow(tCOS, 11.) / 42240. +
                  10395. * pow(tCOS, 13.) / 599040 + 135135. * pow(tCOS, 15.) / 9676800.) *
         57.29577951308238;
  aCOS = (double)xCOS < .7 ? 90 - dround(aCOS, 2) : dround(aCOS, 2);
  return (pCOS < 0. ? 180 - aCOS : aCOS);
}

double _arctan(double xTAN)
{
  double pTAN, tTAN, aTAN;
  pTAN = xTAN;
  xTAN = _fabs(xTAN);
  tTAN = (double)xTAN <= 1. ? pow((1. - (1. / (pow(xTAN, 2.) + 1.))), .5) : pow((1. / (pow(xTAN, 2.) + 1.)), .5);
  aTAN = (double)(tTAN + pow(tTAN, 3.) / 6. + 3. * pow(tTAN, 5.) / 40. + 15. * pow(tTAN, 7.) / 336. +
                  105. * pow(tTAN, 9.) / 3456. + 945. * pow(tTAN, 11.) / 42240. +
                  10395. * pow(tTAN, 13.) / 599040 + 135135. * pow(tTAN, 15.) / 9676800.) *
         57.29577951308238;
  aTAN = (double)xTAN > 1. ? 90 - dround(aTAN, 2) : dround(aTAN, 2);
  return (pTAN < 0. ? -aTAN : aTAN);
}

double _csc(double nAngle)
{
  double nSin;
  nSin = _sin(nAngle);
  return (nSin == 0. ? 0. : 1. / nSin);
}

double _sec(double nAngle)
{
  double nCos;
  nCos = _cos(nAngle);
  return (nCos == 0. ? 0. : 1. / nCos);
}

double _cot(double nAngle)
{
  double nSin, nCos;
  nCos = _cos(nAngle);
  nSin = _sin(nAngle);
  return (nSin == 0. ? 0. : nCos / nSin);
}

double _factorial(int nNum)
{
  double nFac = 1.;

  while (nNum-- > 1)
    nFac = (nFac * nNum);

  return (nFac);
}

double _invlog(double nLog)
{
  int x;
  double z, f;
  z = 1. + nLog;
  f = 1.;
  for (x = 2; x < 24; x++)
  {
    f *= x;
    z += (pow(nLog, (double)x) / f);
  }
  return (z);
}

double _dtor(double nAngle)
{
  return ((nAngle / 360.) * 6.283185307179588);
}

double _rtod(double nArc)
{
  return ((nArc / 6.283185307179588) * 360);
}

int _sign(double nNo)
{
  return (nNo > 0. ? 1 : (nNo < 0. ? -1 : 0));
}

/*
double _fabs(double x) {
   return( x<0. ? -x : x); }
*/
/* pwr function returns x raised to positive or negative integer power n
double _pwr(double x, int n)
{
   if (x == 0.0)
      return 0.0;
   else if (n == 0)
      return 1.0;
   else {
      double a = x;
      int i = abs(n);
      while (i-- > 1)
         a *= x;
      if (n > 0)
         return a;
      else
         return 1.0/a;
   }
} */
