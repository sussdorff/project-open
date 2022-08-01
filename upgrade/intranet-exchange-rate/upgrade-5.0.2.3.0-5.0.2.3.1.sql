-- upgrade-5.0.1.0.0-5.0.1.0.1.sql

SELECT acs_log__debug('/packages/intranet-exchange-rate/sql/postgresql/upgrade/upgrade-5.0.2.3.0-5.0.2.3.1.sql','');

-- Fill "holes" (=missing exchange rate entries)
-- with the values from the last manually entered
-- rates. This procedure is "idempotent", so it
-- can be executed at any time.
create or replace function im_exchange_rate_fill_holes (varchar, date, date)
returns integer as $body$
DECLARE
    p_currency			alias for $1;
    p_start_date		alias for $2;
    p_end_date			alias for $3;

    v_rate			numeric;
    row2			RECORD;
    v_exists_p			integer;
    v_manual_p			boolean;
BEGIN
    RAISE NOTICE 'im_exchange_rate_fill_holes: cur=%, start=%, end=%', p_currency, p_start_date, p_end_date;

    -- Loop through all dates and check if there
    -- is a hole (no entry for a date)
    FOR row2 IN
	select  im_day_enumerator as day
	from    im_day_enumerator(p_start_date, p_end_date)
		LEFT OUTER JOIN (
			select  *
			from    im_exchange_rates
			where   currency = p_currency
		) ex on (im_day_enumerator = ex.day)
	where   1=1 -- ex.rate is null
    LOOP
	-- RAISE NOTICE 'im_exchange_rate_fill_holes: cur=%, day=%', p_currency, row2.day;

	-- get the latest manually entered exchange rate
	select  rate into v_rate
	from    im_exchange_rates
	where   day = (
			select  max(day)
			from    im_exchange_rates
			where   day < row2.day
				and currency = p_currency
				and manual_p = 't'
		      )
		and currency = p_currency;

	-- RAISE NOTICE 'im_exchange_rate_fill_holes: rate=%', v_rate;
	-- use the latest exchange rate for the next few years...
	select  1, manual_p into v_exists_p, v_manual_p
	from im_exchange_rates
	where day = row2.day and currency = p_currency;

	IF (v_manual_p) THEN continue; END IF;		  -- never overwrite manually entered values

	IF v_exists_p > 0 THEN
		update im_exchange_rates
		set     rate = v_rate,
			manual_p = 'f'
		where   day = row2.day
			and currency = p_currency;
	ELSE
		RAISE NOTICE 'im_exchange_rate_fill_holes: day=%, cur=%, rate=%, x=%',row2.day, p_currency, v_rate, v_exists_p;
		insert into im_exchange_rates (
			day, rate, currency, manual_p
		) values (
			row2.day, v_rate, p_currency, 'f'
		);
	END IF;
    END LOOP;

    return 0;
end;$body$ language 'plpgsql';

