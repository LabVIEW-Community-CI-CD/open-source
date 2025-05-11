############################################################
# splitted_metrics.py
# Gathers BFS splitted variables from DB for [start_dt..end_dt)
# and logs EXACT queries (no placeholders).
#
# We separate:
#   mergesRaw
#   closedIssRaw, closedPRRaw
#   forksRaw
#   starsRaw
#   newIssRaw
#   commentsIssRaw, commentsPRRaw
#   reactIssRaw, reactPRRaw
#   pullRaw
############################################################

import mysql.connector
import re
from db_config import DB_HOST, DB_USER, DB_PASSWORD, DB_DATABASE

def get_db_connection():
    return mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_DATABASE
    )

def _escape_single_quotes(val):
    return val.replace("'","\\'")

def _inject_params_into_sql(query_str, param_list):
    """
    Transforms a query with '%s' placeholders into a final
    literal SQL statement, substituting param values with basic
    string escaping. This allows copy/paste into MySQL Workbench.
    """
    final_sql= query_str
    for p in param_list:
        if p is None:
            p_str= "NULL"
        else:
            # convert datetime to string if needed
            if hasattr(p,"strftime"):
                p= p.strftime("%Y-%m-%d %H:%M:%S")
            p_str= str(p)
            p_str= _escape_single_quotes(p_str)
            p_str= f"'{p_str}'"
        final_sql= final_sql.replace("%s", p_str, 1)
    return final_sql

def gather_data_for_window(repo_name, start_dt, end_dt):
    """
    Returns a dict of splitted BFS raw variables for [start_dt..end_dt),
    plus 'queriesUsed' capturing actual SQL used with param injection.
    """
    results= {
      "mergesRaw": 0,
      "closedIssRaw": 0,
      "closedPRRaw": 0,
      "forksRaw": 0,
      "starsRaw": 0,
      "newIssRaw": 0,
      "commentsIssRaw": 0,
      "commentsPRRaw": 0,
      "reactIssRaw": 0,
      "reactPRRaw": 0,
      "pullRaw": 0,
      "queriesUsed": {}
    }

    cnx= get_db_connection()
    cursor= cnx.cursor(buffered=True)

    # mergesRaw => from pull_events, event='merged'
    q_merges= """
      SELECT COUNT(*)
      FROM pull_events
      WHERE repo_name=%s
        AND ((created_at >= %s AND created_at < %s) AND (JSON_EXTRACT(raw_json,'$.event')='closed'))
    """
    pm= (repo_name, start_dt, end_dt)
    cursor.execute(q_merges, pm)
    merges_val= cursor.fetchone()[0] if cursor.rowcount!=-1 else 0
    results["mergesRaw"]= merges_val
    results["queriesUsed"]["mergesRaw"]= {
       "originalSQL": q_merges.strip(),
       "finalSQL": _inject_params_into_sql(q_merges, pm)
    }

    # closedIssRaw => from issue_events, event='closed'
    q_ci= """
      SELECT COUNT(*)
      FROM issue_events ie
      WHERE ie.repo_name=%s
        AND ie.created_at >= %s AND ie.created_at < %s
        AND JSON_EXTRACT(ie.raw_json,'$.event')='closed'
        AND ie.issue_number IN (
           SELECT i.issue_number FROM issues i WHERE i.repo_name=%s
        )
    """
    pci= (repo_name, start_dt, end_dt, repo_name)
    cursor.execute(q_ci, pci)
    ci_val= cursor.fetchone()[0] if cursor.rowcount!=-1 else 0
    results["closedIssRaw"]= ci_val
    results["queriesUsed"]["closedIssRaw"]= {
       "originalSQL": q_ci.strip(),
       "finalSQL": _inject_params_into_sql(q_ci, pci)
    }

    # closedPRRaw => from pull_events event in ('closed','merged')
    q_cpr= """
      SELECT COUNT(*)
      FROM pull_events
      WHERE repo_name=%s
        AND created_at >= %s AND created_at < %s
        AND JSON_EXTRACT(raw_json,'$.event') in ('closed')
    """
    pcpr= (repo_name, start_dt, end_dt)
    cursor.execute(q_cpr, pcpr)
    cpr_val= cursor.fetchone()[0] if cursor.rowcount!=-1 else 0
    results["closedPRRaw"]= cpr_val
    results["queriesUsed"]["closedPRRaw"]= {
       "originalSQL": q_cpr.strip(),
       "finalSQL": _inject_params_into_sql(q_cpr, pcpr)
    }

    # forksRaw
    q_forks= """
      SELECT COUNT(*)
      FROM forks
      WHERE repo_name=%s
        AND created_at >= %s
        AND created_at < %s
    """
    pf= (repo_name, start_dt, end_dt)
    cursor.execute(q_forks, pf)
    f_val= cursor.fetchone()[0] if cursor.rowcount!=-1 else 0
    results["forksRaw"]= f_val
    results["queriesUsed"]["forksRaw"]= {
       "originalSQL": q_forks.strip(),
       "finalSQL": _inject_params_into_sql(q_forks, pf)
    }

    # starsRaw
    q_stars= """
      SELECT COUNT(*)
      FROM stars
      WHERE repo_name=%s
        AND starred_at >= %s
        AND starred_at < %s
    """
    ps= (repo_name, start_dt, end_dt)
    cursor.execute(q_stars, ps)
    s_val= cursor.fetchone()[0] if cursor.rowcount!=-1 else 0
    results["starsRaw"]= s_val
    results["queriesUsed"]["starsRaw"]= {
       "originalSQL": q_stars.strip(),
       "finalSQL": _inject_params_into_sql(q_stars, ps)
    }

    # newIssRaw => issues.created_at
    q_niss= """
      SELECT COUNT(*)
      FROM issues
      WHERE repo_name=%s
        AND created_at >= %s AND created_at < %s
    """
    pniss= (repo_name, start_dt, end_dt)
    cursor.execute(q_niss, pniss)
    niss_val= cursor.fetchone()[0] if cursor.rowcount!=-1 else 0
    results["newIssRaw"]= niss_val
    results["queriesUsed"]["newIssRaw"]= {
       "originalSQL": q_niss.strip(),
       "finalSQL": _inject_params_into_sql(q_niss, pniss)
    }

    # pullRaw => from pulls.created_at
    q_pr= """
      SELECT COUNT(*)
      FROM pulls
      WHERE repo_name=%s
        AND created_at >= %s AND created_at < %s
    """
    ppr= (repo_name, start_dt, end_dt)
    cursor.execute(q_pr, ppr)
    pr_val= cursor.fetchone()[0] if cursor.rowcount!=-1 else 0
    results["pullRaw"]= pr_val
    results["queriesUsed"]["pullRaw"]= {
       "originalSQL": q_pr.strip(),
       "finalSQL": _inject_params_into_sql(q_pr, ppr)
    }

    # commentsIssRaw => ignoring +1/-1 => body not like
    q_c_iss= """
      SELECT COUNT(*)
      FROM issue_comments ic
      JOIN issues i ON (i.repo_name=ic.repo_name AND i.issue_number=ic.issue_number)
      WHERE ic.repo_name=%s
        AND ic.created_at >= %s AND ic.created_at < %s
        AND (ic.body NOT LIKE '%+1%' AND ic.body NOT LIKE '%-1%')
    """
    pciss= (repo_name, start_dt, end_dt)
    cursor.execute(q_c_iss, pciss)
    ciss_val= cursor.fetchone()[0] if cursor.rowcount!=-1 else 0
    results["commentsIssRaw"]= ciss_val
    results["queriesUsed"]["commentsIssRaw"]= {
       "originalSQL": q_c_iss.strip(),
       "finalSQL": _inject_params_into_sql(q_c_iss, pciss)
    }

    # commentsPRRaw => ignoring +1/-1 => body not like
    q_c_pr= """
      SELECT COUNT(*)
      FROM issue_comments ic
      JOIN pulls p ON (p.repo_name=ic.repo_name AND p.pull_number=ic.issue_number)
      WHERE ic.repo_name=%s
        AND ic.created_at >= %s AND ic.created_at < %s
        AND (ic.body NOT LIKE '%+1%' AND ic.body NOT LIKE '%-1%')
    """
    pcpr2= (repo_name, start_dt, end_dt)
    cursor.execute(q_c_pr, pcpr2)
    cpr_val2= cursor.fetchone()[0] if cursor.rowcount!=-1 else 0
    results["commentsPRRaw"]= cpr_val2
    results["queriesUsed"]["commentsPRRaw"]= {
       "originalSQL": q_c_pr.strip(),
       "finalSQL": _inject_params_into_sql(q_c_pr, pcpr2)
    }

    # reactIssRaw => +1/-1 in issues
    q_r_iss= """
      SELECT COUNT(*)
      FROM issue_comments ic
      JOIN issues i ON (i.repo_name=ic.repo_name AND i.issue_number=ic.issue_number)
      WHERE ic.repo_name=%s
        AND ic.created_at >= %s AND ic.created_at < %s
        AND (ic.body LIKE '%+1%' OR ic.body LIKE '%-1%')
    """
    priss= (repo_name, start_dt, end_dt)
    cursor.execute(q_r_iss, priss)
    ri_val= cursor.fetchone()[0] if cursor.rowcount!=-1 else 0
    results["reactIssRaw"]= ri_val
    results["queriesUsed"]["reactIssRaw"]= {
       "originalSQL": q_r_iss.strip(),
       "finalSQL": _inject_params_into_sql(q_r_iss, priss)
    }

    # reactPRRaw => +1/-1 in PRs
    q_r_pr= """
      SELECT COUNT(*)
      FROM issue_comments ic
      JOIN pulls p ON (p.repo_name=ic.repo_name AND p.pull_number=ic.issue_number)
      WHERE ic.repo_name=%s
        AND ic.created_at >= %s AND ic.created_at < %s
        AND (ic.body LIKE '%+1%' OR ic.body LIKE '%-1%')
    """
    prpr= (repo_name, start_dt, end_dt)
    cursor.execute(q_r_pr, prpr)
    rpr_val= cursor.fetchone()[0] if cursor.rowcount!=-1 else 0
    results["reactPRRaw"]= rpr_val
    results["queriesUsed"]["reactPRRaw"]= {
       "originalSQL": q_r_pr.strip(),
       "finalSQL": _inject_params_into_sql(q_r_pr, prpr)
    }

    cursor.close()
    cnx.close()
    return results
