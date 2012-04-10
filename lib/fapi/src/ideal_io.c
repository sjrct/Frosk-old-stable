//
// ideal_io.c
//
// written by sjrct
//
// psuedo
//

int ideal_read(char * buf, int bsize, long long lba, int bl)
{
	if (_drvr_exists(_DRVR_DIO1))
		return _drvr_call(_DRVR_DIO1, _FID_READ, buf, bsize, lba, bl);
	else if (_drvr_exists(_DRVR_DIO2))
		return _drvr_call(_DRVR_DIO2, _FID_READ, buf, bsize, lba, bl);
	return _sys_call(_FID_READ, buf, bsize, lba, bl);
}

int ideal_write(char * buf, long long lba, int bl)
{
	if (_drvr_exists(_DRVR_DIO1))
		return _drvr_call(_DRVR_DIO1, _FID_WRITE, buf, bsize, lba, bl);
	else if (_drvr_exists(_DRVR_DIO2))
		return _drvr_call(_DRVR_DIO2, _FID_WRITE, buf, bsize, lba, bl);
	return _sys_call(_FID_WRITE, buf, bsize, lba, bl);
}
