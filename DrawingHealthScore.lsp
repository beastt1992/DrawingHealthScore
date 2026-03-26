;;; ============================================================
;;; DrawingHealthScore.lsp  (DHS / DHSFIX)
;;; Drawing Health Score Tool - Pro v4.2 (UI Layout Optimized)
;;; Commands: DHS = open scanner & fix dashboard
;;; ============================================================
(vl-load-com)

;;; -- Global vars for before/after comparison ----------------
(setq *dhs-old-kb* nil)
(setq *dhs-old-obj* nil)

;;; -- Scoring helpers ----------------------------------------
(defun dhs:score-10 (val warn-at fail-at)
  (cond
    ((= val 0)             10)
    ((< val warn-at)        8)
    ((< val fail-at)        6)
    ((< val (* fail-at 2))  4)
    (t                      2)))

(defun dhs:tag (score)
  (cond
    ((>= score 8) "[GOOD]")
    ((>= score 6) "[WARN]")
    (t            "[FAIL]")))

(defun dhs:get-file-kb (/ fname)
  (setq fname (findfile (getvar "DWGNAME")))
  (if fname (fix (/ (float (vl-file-size fname)) 1024)) 0))

;;; -- Master Flow Logic ---------------------------------------
(defun dhs:run-dashboard ( is-postfix /
  ss i total elist lay typ bname sname
  u-lay u-blk u-sty lay-0-cnt
  r1 s1 r2 s2 r3 s3 r5 s5 r6 s6 r7 s7
  s8 kb8 obj8 xr-total xr-bad s9
  tbl lname bflags pct100 saved-kb saved-mb new-mb ratio
  dcl_file fn dcl_id res do_purge do_audit do_save doc ss-tmp)

  (princ "\n>> Scanning drawing data... ")
  
  ;; --- 1. Fast Scanning ---
  (setq u-lay nil u-blk nil u-sty nil)
  (setq lay-0-cnt 0 total 0)
  
  (if (setq ss (ssget "_X"))
    (progn
      (setq total (sslength ss))
      (setq i 0)
      (while (< i total)
        (setq elist (entget (ssname ss i)))
        (setq lay (cdr (assoc 8 elist)))
        (setq typ (cdr (assoc 0 elist)))

        (if (= lay "0") (setq lay-0-cnt (1+ lay-0-cnt)))
        (if (not (member lay u-lay)) (setq u-lay (cons lay u-lay)))
        (if (= typ "INSERT")
          (progn (setq bname (cdr (assoc 2 elist))) (if (not (member bname u-blk)) (setq u-blk (cons bname u-blk)))))
        (if (or (= typ "TEXT") (= typ "MTEXT"))
          (progn (setq sname (cdr (assoc 7 elist))) (if (not (member sname u-sty)) (setq u-sty (cons sname u-sty)))))
        (setq i (1+ i))
      )
    )
  )

  ;; --- 2. Analyzing Data ---
  (setq r1 0 tbl (tblnext "LAYER" T))
  (while tbl
    (setq lname (cdr (assoc 2 tbl)))
    (if (and (not (equal lname "0")) (not (equal lname "Defpoints")) (not (vl-string-search "|" lname)))
      (if (not (member lname u-lay)) (setq r1 (1+ r1))))
    (setq tbl (tblnext "LAYER")))
  (setq s1 (dhs:score-10 r1 5 20))

  (setq r2 0 r6 0 tbl (tblnext "BLOCK" T))
  (while tbl
    (setq bname (cdr (assoc 2 tbl)) bflags (cdr (assoc 70 tbl)))
    (if (not (and bflags (> (logand bflags 4) 0)))
      (progn
        (if (or (= (substr bname 1 1) "*") (= (substr bname 1 1) "_"))
          (if (or (= (substr bname 1 2) "*U") (= (substr bname 1 2) "*D") (= (substr bname 1 2) "*X")) (setq r6 (1+ r6)))
          (if (not (member bname u-blk)) (setq r2 (1+ r2))))))
    (setq tbl (tblnext "BLOCK")))
  (setq s2 (dhs:score-10 r2 5 10) s6 (dhs:score-10 r6 20 50))

  (setq r3 lay-0-cnt s3 (dhs:score-10 r3 10 20))
  (setq r5 (length u-sty) s5 (dhs:score-10 r5 3 5))

  (setq r7 0 tbl (tblnext "LAYER" T))
  (while tbl
    (setq lname (cdr (assoc 2 tbl)))
    (if (and (not (equal lname "0")) (<= (strlen lname) 2) (not (vl-string-search "|" lname))) (setq r7 (1+ r7)))
    (setq tbl (tblnext "LAYER")))
  (setq s7 (dhs:score-10 r7 3 8))

  (setq kb8 (dhs:get-file-kb) obj8 total ratio (/ (float kb8) (if (> obj8 0) obj8 1)))
  (setq s8 (cond ((< ratio 1.5) 10) ((< ratio 3.0) 8) ((< ratio 6.0) 6) ((< ratio 10.0) 4) (t 2))) 

  (setq xr-total 0 xr-bad 0 tbl (tblnext "BLOCK" T))
  (while tbl
    (setq bflags (cdr (assoc 70 tbl)))
    (if (and bflags (> (logand bflags 4) 0))
      (progn (setq xr-total (1+ xr-total)) (if (> (logand bflags 16) 0) (setq xr-bad (1+ xr-bad)))))
    (setq tbl (tblnext "BLOCK")))
  (setq s9 (if (> xr-bad 0) 4 10))

  (setq pct100 (fix (* 100.0 (/ (float (+ s1 s2 s3 s5 s6 s7 s8 s9)) 80.0))))
  (setq new-mb (rtos (/ (float kb8) 1024.0) 2 2))

  ;; Calculate space saved if post-fix
  (setq saved-mb "")
  (if (and is-postfix *dhs-old-kb* (> *dhs-old-kb* 0))
    (progn
      (setq saved-kb (- *dhs-old-kb* kb8))
      (if (> saved-kb 0)
        (setq saved-mb (strcat "         -> Space Saved: " (rtos (/ (float saved-kb) 1024.0) 2 2) " MB !!"))
      )
      (setq *dhs-old-kb* nil *dhs-old-obj* nil)
    )
  )

  (princ "Done.\n")

  ;; --- 3. Dynamic DCL GUI Generation ---
  (setq dcl_file (vl-filename-mktemp "dhs_dash.dcl"))
  (setq fn (open dcl_file "w"))
  (write-line "dhs_dash_dlg : dialog {" fn)
  (write-line "  label = \"Drawing Health Score Dashboard\";" fn)
  (write-line "  : column {" fn)
  
  ;; Score Header
  (write-line "    : text { key = \"t_score\"; alignment = centered; }" fn)
  (write-line "    : text { key = \"t_status\"; alignment = centered; }" fn)
  (write-line "    spacer;" fn)
  
  ;; Diagnostic Section (Reordered File Weight to the bottom)
  (write-line "    : boxed_column {" fn)
  (write-line "      label = \"Diagnostic Report\";" fn)
  (write-line "      : text { key = \"t_1\"; }" fn)
  (write-line "      : text { key = \"t_2\"; }" fn)
  (write-line "      : text { key = \"t_3\"; }" fn)
  (write-line "      : text { key = \"t_5\"; }" fn)
  (write-line "      : text { key = \"t_6\"; }" fn)
  (write-line "      : text { key = \"t_7\"; }" fn)
  (write-line "      : text { key = \"t_9\"; }" fn) ; Moved Xref up
  (write-line "      : text { key = \"t_8\"; }" fn) ; Moved File weight down
  (write-line "      : text { key = \"t_8b\"; }" fn) ; Space saved message at the absolute bottom
  (write-line "    }" fn)
  
  ;; Fix Options Section
  (write-line "    : boxed_column {" fn)
  (write-line "      label = \"Auto-Fix Settings\";" fn)
  (write-line "      : toggle { key = \"cb_purge\"; label = \"Deep PURGE (Clean unused layers/blocks)\"; value = \"1\"; }" fn)
  (write-line "      : toggle { key = \"cb_audit\"; label = \"AUDIT (Fix database errors in background)\"; value = \"1\"; }" fn)
  (write-line "      : toggle { key = \"cb_save\"; label = \"Auto-Save (Required to calculate MB saved)\"; value = \"1\"; }" fn)
  (write-line "    }" fn)
  
  ;; Custom Buttons
  (write-line "    : row {" fn)
  (write-line "      : button { key = \"btn_fix\"; label = \"Run Fix Now\"; is_default = true; }" fn)
  (write-line "      : button { key = \"cancel\"; label = \"Close\"; is_cancel = true; }" fn)
  (write-line "    }" fn)
  (write-line "  }" fn)
  (write-line "}" fn)
  (close fn)
  
  ;; --- 4. Load & Display Dialog ---
  (setq dcl_id (load_dialog dcl_file))
  (if (not (new_dialog "dhs_dash_dlg" dcl_id))
    (progn (princ "\n>> Error: Cannot load graphical interface.") (exit))
  )
  
  ;; Populate Text Tiles
  (set_tile "t_score" (strcat "OVERALL SCORE: " (itoa pct100) " / 100"))
  (set_tile "t_status" (cond ((>= pct100 80) "Status: GOOD") ((>= pct100 60) "Status: FAIR") (t "Status: POOR (Fix Required)")))
  
  (set_tile "t_1" (strcat (dhs:tag s1) " Unused layers: " (itoa r1)))
  (set_tile "t_2" (strcat (dhs:tag s2) " Unpurged blocks: " (itoa r2)))
  (set_tile "t_3" (strcat (dhs:tag s3) " Layer 0 objects: " (itoa r3)))
  (set_tile "t_5" (strcat (dhs:tag s5) " Text styles: " (itoa r5) " used"))
  (set_tile "t_6" (strcat (dhs:tag s6) " Anonymous blocks: " (itoa r6)))
  (set_tile "t_7" (strcat (dhs:tag s7) " Short layer names: " (itoa r7)))
  (set_tile "t_9" (strcat (dhs:tag s9) " Xref issues: " (if (> xr-bad 0) (itoa xr-bad) "None")))
  (set_tile "t_8" (strcat (dhs:tag s8) " File weight: " new-mb " MB"))
  (set_tile "t_8b" saved-mb)

  ;; Bind Actions
  (action_tile "btn_fix" 
    "(setq do_purge (atoi (get_tile \"cb_purge\")))
     (setq do_audit (atoi (get_tile \"cb_audit\")))
     (setq do_save (atoi (get_tile \"cb_save\")))
     (done_dialog 1)"
  )
  (action_tile "cancel" "(done_dialog 0)")
  
  ;; Start Dialog
  (setq res (start_dialog))
  
  ;; Cleanup UI files
  (unload_dialog dcl_id)
  (vl-file-delete dcl_file)
  
  ;; --- 5. Execute Fixes if Button Clicked ---
  (if (= res 1)
    (progn
      (if (or (= do_purge 1) (= do_audit 1) (= do_save 1))
        (progn
          (princ "\n>> Applying fixes in background... Please wait.")
          (setq *dhs-old-kb* kb8)
          (setq *dhs-old-obj* obj8)
          (setq doc (vla-get-activedocument (vlax-get-acad-object)))
          
          (if (= do_purge 1) (repeat 3 (vla-purgeall doc)))
          (if (= do_audit 1) (vla-auditinfo doc :vlax-true))
          (if (= do_save 1) (command "_.QSAVE") (setq *dhs-old-kb* nil))
          
          ;; Loop back to show updated dashboard
          (dhs:run-dashboard T)
        )
        (princ "\n>> No fix options selected.\n")
      )
    )
    (princ "\n>> Dashboard closed.\n")
  )
  (princ)
)

;;; -- Commands -----------------------------------------------
(defun C:DHS () 
  (repeat 10 (terpri))
  (dhs:run-dashboard nil)
)

(defun C:DHSFIX () (C:DHS))
(defun C:DHSF () (C:DHS))

(princ "\nDrawingHealthScore v4.2 loaded. Type DHS to open Dashboard.")
(princ)