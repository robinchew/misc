# -*- coding: utf-8 -*-
#
# Copyright (C) 2003-2009 Edgewall Software
# Copyright (C) 2003-2005 Daniel Lundin <daniel@edgewall.com>
# All rights reserved.
#
# This software is licensed as described in the file COPYING, which
# you should have received as part of this distribution. The terms
# are also available at http://trac.edgewall.org/wiki/TracLicense.
#
# This software consists of voluntary contributions made by many
# individuals. For the exact contribution history, see the revision
# history and logs, available at http://trac.edgewall.org/log/.
#
# Author: Daniel Lundin <daniel@edgewall.com>

from trac.db import Table, Column, Index

# Database version identifier. Used for automatic upgrades.
db_version = 21

def __mkreports(reports):
    """Utility function used to create report data in same syntax as the
    default data. This extra step is done to simplify editing the default
    reports."""
    result = []
    for report in reports:
        result.append((None, report[0], report[2], report[1]))
    return result


##
## Database schema
##

schema = [
    # Common
    Table('system', key='name')[
        Column('name'),
        Column('value')],
    Table('permission', key=('username', 'action'))[
        Column('username'),
        Column('action')],
    Table('auth_cookie', key=('cookie', 'ipnr', 'name'))[
        Column('cookie'),
        Column('name'),
        Column('ipnr'),
        Column('time', type='int')],
    Table('session', key=('sid', 'authenticated'))[
        Column('sid'),
        Column('authenticated', type='int'),
        Column('last_visit', type='int'),
        Index(['last_visit']),
        Index(['authenticated'])],
    Table('session_attribute', key=('sid', 'authenticated', 'name'))[
        Column('sid'),
        Column('authenticated', type='int'),
        Column('name'),
        Column('value')],

    # Attachments
    Table('attachment', key=('type', 'id', 'filename'))[
        Column('type'),
        Column('id'),
        Column('filename'),
        Column('size', type='int'),
        Column('time', type='int'),
        Column('description'),
        Column('author'),
        Column('ipnr')],

    # Wiki system
    Table('wiki', key=('name', 'version'))[
        Column('name'),
        Column('version', type='int'),
        Column('time', type='int'),
        Column('author'),
        Column('ipnr'),
        Column('text'),
        Column('comment'),
        Column('readonly', type='int'),
        Index(['time'])],

    # Version control cache
    Table('revision', key='rev')[
        Column('rev'),
        Column('time', type='int'),
        Column('author'),
        Column('message'),
        Index(['time'])],
    Table('node_change', key=('rev', 'path', 'change_type'))[
        Column('rev'),
        Column('path'),
        Column('node_type', size=1),
        Column('change_type', size=1),
        Column('base_path'),
        Column('base_rev'),
        Index(['rev'])],

    # Ticket system
    Table('ticket', key='id')[
        Column('id', auto_increment=True),
        Column('type'),
        Column('time', type='int'),
        Column('changetime', type='int'),
        Column('component'),
        Column('severity'),
        Column('priority'),
        Column('owner'),
        Column('reporter'),
        Column('cc'),
        Column('version'),
        Column('milestone'),
        Column('status'),
        Column('resolution'),
        Column('summary'),
        Column('description'),
        Column('keywords'),
        Index(['time']),
        Index(['status'])],    
    Table('ticket_change', key=('ticket', 'time', 'field'))[
        Column('ticket', type='int'),
        Column('time', type='int'),
        Column('author'),
        Column('field'),
        Column('oldvalue'),
        Column('newvalue'),
        Index(['ticket']),
        Index(['time'])],
    Table('ticket_custom', key=('ticket', 'name'))[
        Column('ticket', type='int'),
        Column('name'),
        Column('value')],
    Table('enum', key=('type', 'name'))[
        Column('type'),
        Column('name'),
        Column('value')],
    Table('component', key='name')[
        Column('name'),
        Column('owner'),
        Column('description')],
    Table('milestone', key='name')[
        Column('name'),
        Column('due', type='int'),
        Column('completed', type='int'),
        Column('description')],
    Table('version', key='name')[
        Column('name'),
        Column('time', type='int'),
        Column('description')],

    # Report system
    Table('report', key='id')[
        Column('id', auto_increment=True),
        Column('author'),
        Column('title'),
        Column('query'),
        Column('description')],
]


##
## Default Reports
##

def get_reports(db):
    return (
('Active Tickets',
"""
custom query
""",
"""
query:?status=accepted
&
status=assigned
&
status=new
&
status=reopened
&
col=id
&
col=priority
&
col=summary
&
col=status
&
col=owner
&
col=cc
&
col=reporter
&
col=changetime
&
report=8
&
desc=1
&
order=changetime
"""),
)


##
## Default database values
##

# (table, (column1, column2), ((row1col1, row1col2), (row2col1, row2col2)))
def get_data(db):
   return (('component',
             ('name', 'owner'),
               (('general', 'robin'),
               )),
           ('enum',
             ('type', 'name', 'value'),
               (('resolution', 'fixed', 1),
                ('resolution', 'invalid', 2),
                ('resolution', 'wontfix', 3),
                ('resolution', 'duplicate', 4),
                ('priority', 'critical', 2),
                ('priority', 'major', 3),
                ('priority', 'minor', 4),
                ('priority', 'trivial', 5),
                ('ticket_type', 'bug/defect', 1),
                ('ticket_type', 'feature/enhancement', 2),
                ('ticket_type', 'task', 3))),
           ('permission',
             ('username', 'action'),(
                ('authenticated', 'WIKI_CREATE'),
                ('authenticated', 'WIKI_MODIFY'),
                ('authenticated', 'TICKET_CREATE'),
                ('authenticated', 'TICKET_MODIFY'),
                ('staff', 'BROWSER_VIEW'),
                ('staff', 'WIKI_CREATE'),
                ('staff', 'WIKI_VIEW'),
                ('staff', 'WIKI_MODIFY'),
		('staff','REPORT_VIEW'),
		('staff','TICKET_VIEW'),
		('staff','TICKET_APPEND'),
		('staff','TICKET_CREATE'),
		('staff','TIMELINE_VIEW'),
		('staff','LOG_VIEW'),
		('staff','CHANGESET_VIEW'),
		('staff','FILE_VIEW'),
		('staff','TICKET_EDIT_CC'),
		('staff','TICKET_EDIT_DESCRIPTION'),
		('staff','TICKET_CHGPROP'),
		('staff','MILESTONE_ADMIN'),
		('staff','TICKET_MODIFY'),
		('staff','SEARCH_VIEW'),
		('charles','staff'),
		('phillllip','staff'),
		('philip','staff'),
		('martogi','staff'),
		('handy','staff'),
		('test','staff'),
		('yoko','staff'),
		('methilda','staff'),
		('mharten','staff'),
		('christianus','staff'),
		('andy','staff'),
		('ibnu','staff'),
		('ivan','staff'),
		('marena','staff'),
		('robin','TRAC_ADMIN'),
		)),
           ('session',
             ('sid', 'authenticated','last_visit'),
               (('andy',1,0),
		('mharten',1,0),
		('marena',1,0),
		('christianus',1,0),
		('charles',1,0),
		('yoko',1,0),
		('ivan',1,0),
		('martogi',1,0),
		('phillllip',1,0),
		('philip',1,0),
		('handy',1,0),
		('robin',1,0),
		)),
           ('session_attribute',
             ('sid', 'authenticated','name','value'),
               (('andy',1,'email','ad1x@hotmail.com'),
		('mharten',1,'email','methilda.harten@empiriamedia.com'),
		('marena',1,'email','Marena.Hartini@empiriamedia.com'),
		('christianus',1,'email','Christianus.hermawan@empiriamedia.com'),
		('charles',1,'email','charles.sugio@empiriamedia.com'),
		('yoko',1,'email','yoko_halim@yahoo.com'),
		('ivan',1,'email','ivan.chandra@gandaerah.com'),
		('martogi',1,'email','craker_devil84@yahoo.com'),
		('phillllip',1,'email','min.siung@gmail.com'),
		('philip',1,'email','min.siung@gmail.com'),
		('handy',1,'email','handy_venom01@yahoo.com'),
		('robin',1,'email','robinchew@gmail.com'),
		)),
           ('system',
             ('name', 'value'),
               (('database_version', str(db_version)),
                ('initial_database_version', str(db_version)),
                ('youngest_rev', ''))),
           ('report',
             ('author', 'title', 'query', 'description'),
               __mkreports(get_reports(db))))
