subroutine renormalization_factor(COHSEX,eta,nBas,nC,nO,nV,nR,nS,e,Omega,rho,Z)

! Compute renormalization factor for GW

  implicit none
  include 'parameters.h'

! Input variables

  logical,intent(in)            :: COHSEX
  double precision,intent(in)   :: eta
  integer,intent(in)            :: nBas,nC,nO,nV,nR,nS
  double precision,intent(in)   :: e(nBas)
  double precision,intent(in)   :: Omega(nS)
  double precision,intent(in)   :: rho(nBas,nBas,nS)

! Local variables

  integer                       :: i,j,a,b,x,jb
  double precision              :: eps

! Output variables

  double precision,intent(out)  :: Z(nBas)

! Initialize

  Z(:)  = 0d0

! static COHSEX approximation

  if(COHSEX) then
    
    Z(:) = 1d0
    return
 
  else

    ! Occupied part of the correlation self-energy

    do x=nC+1,nBas-nR
      do i=nC+1,nO
        jb = 0
        do j=nC+1,nO
          do b=nO+1,nBas-nR
            jb = jb + 1
            eps = e(x) - e(i) + Omega(jb) 
            Z(x) = Z(x)  - 2d0*rho(x,i,jb)**2*(eps/(eps**2 + eta**2))**2
          end do
        end do
      end do
    end do

    ! Virtual part of the correlation self-energy

    do x=nC+1,nBas-nR
      do a=nO+1,nBas-nR
        jb = 0
        do j=nC+1,nO
          do b=nO+1,nBas-nR
            jb = jb + 1
            eps = e(x) - e(a) - Omega(jb) 
            Z(x) = Z(x)  - 2d0*rho(x,a,jb)**2*(eps/(eps**2 + eta**2))**2
          end do
        end do
      end do
    end do

  end if

! Compute renormalization factor from derivative of SigC
 
  Z(:) = 1d0/(1d0 - Z(:))

end subroutine renormalization_factor
