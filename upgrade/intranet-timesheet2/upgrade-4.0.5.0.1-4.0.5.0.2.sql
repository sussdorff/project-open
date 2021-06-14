-- upgrade-4.0.5.0.1-4.0.5.0.2.sql

SELECT acs_log__debug('/packages/intranet-timesheet2/sql/postgresql/upgrade/upgrade-4.0.5.0.1-4.0.5.0.2.sql','');


CREATE OR REPLACE FUNCTION inline_0 ()
RETURNS INTEGER AS $$
DECLARE
        v_count                 integer;
BEGIN
	SELECT	count(*) into v_count FROM user_tab_columns
	WHERE 	lower(table_name) = 'im_user_absences' and
		lower(column_name) = 'vacation_replacement_id';

	IF v_count > 0 THEN return 1; END IF;

	ALTER TABLE im_user_absences
	ADD column vacation_replacement_id integer
	CONSTRAINT im_user_absences_vacation_replacement_fk REFERENCES parties;

        return 0;
END;$$ LANGUAGE 'plpgsql';
SELECT inline_0 ();
DROP FUNCTION inline_0 ();



SELECT im_dynfield_widget__new (
	null, 'im_dynfield_widget', now(), 0, '0.0.0.0', null,
	'absence_vacation_replacements', 'Absence Vacation Replacements', 'Absence Vacation Replacements',
	10007, 'integer', 'generic_sql', 'integer',
	'{custom {sql {
		select	p.person_id,
			im_name_from_user_id(p.person_id) as person_name
		from 
			persons p
		where
			p.person_id in (
				select	member_id
				from	group_distinct_member_map
				where	group_id in (
						select	group_id
						from	groups
						where	group_name = ''Employees''
					)
			)
		order by 
			lower(first_names), lower(last_name)
	}}}'
);

SELECT im_dynfield_attribute_new ('im_user_absence', 'vacation_replacement_id', 'Vacation Replacement', 'absence_vacation_replacements', 'integer', 'f');


