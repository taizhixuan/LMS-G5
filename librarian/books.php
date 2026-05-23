<?php include('header.php'); ?>
<?php include('session.php'); ?>
<?php include('navbar_books.php'); ?>
    <div class="container">
		<div class="margin-top">
			<div class="row">	
			<div class="span12">	
			   <div class="alert alert-danger">
                                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                                    <strong><i class="icon-user icon-large"></i>&nbsp;Books Table</strong>
                                </div>
						<!--  -->
								    <ul class="nav nav-pills nav-justified">
										<li   class="active"><a href="books.php">All</a></li>
										<li><a href="new_books.php">New Books</a></li>
										<li><a href="old_books.php">Old Books</a></li>
										<li><a href="lost.php">Lost Books</a></li>
										<li><a href="damage.php">Damage Books</a></li>
										<li><a href="sub_rep.php">Subject for Replacement</a></li>
									</ul>
						<!--  -->
						<center class="title">
						<h1>Books List</h1>
						</center>
                            <table cellpadding="0" cellspacing="0" border="0" class="table  table-bordered" id="example">
								<div class="pull-right">
								<a href="" onclick="window.print()" class="btn-deafult"></i> Print</a>
								</div>
								<p><a href="add_books.php" class="btn-default">&nbsp;Add Books</a></p>
							
                                <thead>
                                    <tr>
									    <th>Acc No.</th>                                 
                                        <th>Book Title</th>                                 
                                        <th>Category</th>
										<th>Author</th>
										<th class="action">copies</th>
										<th>Book Pub</th>
										<th>Publisher Name</th>
										<th>ISBN</th>
										<th>Copyright Year</th>
										<th>Date Added</th>
										<th>Status</th>
										<th class="action">Action</th>		
                                    </tr>
                                </thead>
                                <tbody>
								 
                                  <?php
                                  // E5: single JOIN replaces the prior 2N+1 query loop.
                                  // The available-copies formula is intentionally identical
                                  // to the one used by E1's borrow_save.php validation so
                                  // both code paths share one source of truth.
                                  $user_query = mysqli_query($con, "
                                      SELECT b.book_id, b.book_title, b.author, b.book_copies,
                                             b.book_pub, b.publisher_name, b.isbn,
                                             b.copyright_year, b.date_added, b.status,
                                             c.classname,
                                             b.book_copies - COALESCE(SUM(CASE WHEN bd.borrow_status = 'pending' THEN 1 ELSE 0 END), 0) AS available
                                        FROM book b
                                   LEFT JOIN category      c  ON c.category_id = b.category_id
                                   LEFT JOIN borrowdetails bd ON bd.book_id    = b.book_id
                                       WHERE b.status != 'Archive'
                                    GROUP BY b.book_id, b.book_title, b.author, b.book_copies,
                                             b.book_pub, b.publisher_name, b.isbn,
                                             b.copyright_year, b.date_added, b.status, c.classname
                                    ORDER BY b.book_id
                                  ") or die(mysqli_error($con));
                                  while ($row = mysqli_fetch_array($user_query)) {
                                      $id = $row['book_id'];
                                  ?>
									<tr class="del<?php echo $id ?>">
                                    <td><?php echo $row['book_id']; ?></td>
                                    <td><?php echo $row['book_title']; ?></td>
									<td><?php echo $row['classname']; ?> </td>
                                    <td><?php echo $row['author']; ?> </td>
                                    <td class="action"><?php echo $row['available']; ?> </td>
                                     <td><?php echo $row['book_pub']; ?></td>
									 <td><?php echo $row['publisher_name']; ?></td>
									 <td><?php echo $row['isbn']; ?></td>
									 <td><?php echo $row['copyright_year']; ?></td>		
									 <td><?php echo $row['date_added']; ?></td>
									 <td><?php echo $row['status']; ?></td>
									<?php include('toolttip_edit_delete.php'); ?>
                                    <td class="action">
									<div class="span2">
                                        <a rel="tooltip"  title="Delete" id="<?php echo $id; ?>" href="#delete_book<?php echo $id; ?>" data-toggle="modal"    class="btn-default"><i class="icon-trash icon-large"></i></a>
                                        <?php include('delete_book_modal.php'); ?>
										<div class="span1">
										<a  rel="tooltip"  title="Edit" id="e<?php echo $id; ?>" href="edit_book.php<?php echo '?id='.$id; ?>" class="btn-default"><i class="icon-pencil icon-large"></i></a>
										</div></div>
                                    </td>
									
                                    </tr>
									<?php  }  ?>
                           
                                </tbody>
                            </table>
							
			
			</div>		
			</div>
		</div>
    </div>
<?php include('footer.php') ?>
