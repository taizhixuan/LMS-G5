	<div id="delete_book<?php echo $borrow_details_id; ?>" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<form method="POST" action="return_save.php" style="margin:0;">
			<div class="modal-body">
				<div class="alert alert-success">Do you want to Return this Book?</div>
				<input type="hidden" name="id"       value="<?php echo (int) $id; ?>">
				<input type="hidden" name="book_id"  value="<?php echo (int) $book_id; ?>">
				<?php echo csrf_field(); ?>
			</div>
			<div class="modal-footer">
				<button type="submit" class="btn btn-success">Yes</button>
				<button type="button" class="btn" data-dismiss="modal" aria-hidden="true"><i class="icon-remove icon-large"></i>&nbsp;Close</button>
			</div>
		</form>
    </div>
