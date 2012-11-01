B<In the last 15 years, RRDtool has become an integral part of many monitoring applications.
Its applications have spread far and wide. Way beyond the initial vision. It is used in tiny embedded systems as well as huge enterprise monitoring systems with hundreds of thousands of data sources logging into round robin databases.>

B<My main concerns when designing applications is to come up with simple and logical interfaces, covering all the necessary functionality and providing a path for further enhancement. This has worked very well with RRDtool 1.x, but there are some fundamental design elements that are not so easily changed.>

=head1 VISION

Part of the success of RRDtool is based on the fact, that a single package takes care of all your time series data storage, retrieval and presentation needs. Any future version of RRDtool will do the same, but only more so. The main goal of the 2.x rewrite is to define clear internal APIs for the interaction of the individual components of RRDtool. This will make it possible to replace or drastically modify one component without changes to the rest of the system. To some extent, this pattern was already present in RRDtool 1.x, but especially in the data storage layer the structure does not lend itself to extensions all that well.

=head1 PROJECT

Rewriting RRDtool is a major software engineering effort. To get this done in a deterministic and orderly fashion, development will follow the following path:

=over

=item 1.

Collect requirements, using the GitHub Issue Tracker

=item 2.

Triage requirements

=item 3.

Create a coherent, modular design, down to the internal API level.

=item 4.

Plan and budget the implementation.

=item 5.

Launch a CrowdFunding project to raise the money for the implementation.

=item 6.

Implement

=item 7.

Release 2.x

=back

=head1 REQUIREMENTS

=over

=item Test Suite

All 2.x functionality is exercised by a test suite.

=item Backward Compatibility

The 2.x design addresses all the complex issued not easily changed by altering RRDtool 1.x. Most of the 1.x functionality is present in RRDtool 2.x. An 1.x compatibility API emulates the 1.x behavior on top of the 2.x API.

=back

=head1 FREE SOFTWARE LICENSE

A suitable Free Software License for RRDtool 2.x is to be determined based on feedback from the people financing the development. It could be GNU GPL V2, V3, GNU LGPL

=head1 AUTHOR

Tobi Oetiker E<lt>L<tobi@oetiker.ch>E<gt>

=cut